require 'open-uri'
require 'active_support/core_ext'

class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :details, type: String
  field :name, type: String
  field :user, type: String
  field :datetime, type: Time
  field :width, type: Integer
  field :height, type: Integer
  field :crop_x, type: Integer
  field :crop_y, type: Integer
  field :url, type: String
  field :is_all_day, type: Boolean
  field :time_format, type: String
  field :tv_time , type: String
  field :creation_timezone, type: String
  field :local_time, type: String
  field :local_date, type: Date
  field :date, type: Date
  field :description, type: String
  field :upvote_names, type: Array
  field :upvote_count, type: Integer
  field :country, type: String
  field :location_type, type: String
  field :subkast, type: String

  has_many :reminders
  has_many :comments

  index({local_date:1})
  index({datetime:1})

  validates_length_of :name, minimum: 1, maximum: 100

  has_mongoid_attached_file :image, :styles =>
    {
      :thumb => "80x60^",
      :medium => "400x300^"
    },
    :s3_protocol => :https,
    :processors => [:cropper]

  after_create do |event|
    HipChatNotification.new_event(event)
  end

  before_save do |event|
    event.upvote_count = 0
    if not event.upvote_names.nil?
      event.upvote_count = event.upvote_names.size
    end
  end

  def national?
    location_type == 'national'
  end

  def international?
    location_type == 'international'
  end

  def all_day?
    is_all_day
  end

  def recurring?
    time_format == 'recurring'
  end

  def tv_show?
    time_format == 'tv_show'
  end

  def relative?
    time_format.blank?
  end

  def full_subkast
    Subkast.by_code(subkast).name
  end

  def get_utc_datetime(timezone)
    if is_all_day == true or time_format == 'recurring' or time_format == 'tv_show'
      tz = TZInfo::Timezone.get(timezone)

      return tz.local_to_utc(local_date.to_datetime) if is_all_day
      return tz.local_to_utc(local_datetime) if time_format == 'recurring'

      if time_format == 'tv_show'
        tz = TZInfo::Timezone.get('America/New_York')
        return tz.local_to_utc(local_datetime)
      end
    else
      return datetime
    end
  end

  def get_assumed_time
    return datetime if relative?
    return TZInfo::Timezone.get('America/New_York').local_to_utc(local_datetime) if tv_show?
    return local_datetime if recurring?
  end

  def get_local_datetime(timezone)
    return Time.parse(local_date.to_s) if is_all_day == true

    tz = TZInfo::Timezone.get(timezone)

    if time_format == 'tv_show'
      tz_east = TZInfo::Timezone.get('America/New_York')
      return Time.parse(tz_east.local_to_utc(tz.utc_to_local(local_datetime)).strftime("%Y-%m-%d %H:%M:%S"))
    end

    if time_format == 'recurring'
      return local_datetime
    end

    return Time.parse(tz.utc_to_local(datetime).strftime("%Y-%m-%d %H:%M:%S"))
  end

  def local_datetime
    Time.parse(local_date.to_s + " " + local_time)
  end

  def local_date_with_slashes
    local_date.strftime('%d/%m/%Y')
  end

  def local_hour
    local_time.split(' ')[0].split(':')[0] rescue ''
  end

  def local_minute
    local_time.split(' ')[0].split(':')[1] rescue ''
  end

  def local_ampm
    local_time.split(' ')[1] rescue ''
  end

  def pretty_datetime
    get_local_datetime('America/New_York').strftime('%-d %B, %Y - %A, %l:%M %p')
  end

  def formatted_time(timezone)
    return 'All Day' if is_all_day
    return get_local_datetime(timezone).strftime('%l:%M%P').strip if time_format == 'recurring' || time_format == ''
    return "#{get_local_datetime(timezone).strftime('%l:%M').strip}/#{(get_local_datetime(timezone) - 1.hour).strftime('%l:%M').strip}c"
  end

  def reminders_for_user(user)
    reminders.where(user: user)
  end

  def set_reminder(user, interval)
    Reminder.create(event_id: id, user_id: user.id, time_to_event: interval)
  end

  def remove_reminder(user, interval)
    Reminder.where(event_id: id, user_id: user.id, time_to_event: interval).delete
  end

  def save_event(params)
    update_attribute(:name, params[:name])
    update_attribute(:subkast, params[:subkast])
    update_attribute(:country, params[:country])
    update_attribute(:is_all_day, params[:is_all_day])
    update_attribute(:location_type, params[:location_type])
    update_attribute(:local_date, params[:local_date])
    update_attribute(:local_time, params[:local_time])
    update_attribute(:datetime, params[:datetime])
    update_attribute(:time_format, params[:time_format])
    update_attribute(:description, params[:description])
    update_attribute(:user, params[:user])
  end

  def save_image(params)
    update_attribute(:width, params[:width])
    update_attribute(:height, params[:height])
    update_attribute(:crop_x, params[:crop_x])
    update_attribute(:crop_y, params[:crop_y])

    update_attribute(:image, params[:image]) if params[:image].present?

    image_from_url(params[:url]) if params[:url].present? && !params[:image].present?
  end

  def image_from_url(url)
    if url
      if url.start_with?('data:image/jpeg;base64')
         StringIO.open(Base64.strict_decode64(url.split(',')[1])) do |data|
            data.class.class_eval { attr_accessor :original_filename, :content_type }
            data.original_filename = "temp#{DateTime.now.to_i}.png"
            data.content_type = "image/png" #TODO: get content type from file
            self.image = data
        end
      else
        self.image = open(url)
      end
    else
      self.image = self.no_image()
    end
  end

  def update_image_from_url(url)
    if url != self.image.url(:original)
      self.image_from_url(url)
    else
      self.image.reprocess!
    end
  end


  def no_image
    File.open("#{Rails.root}/public/images/thumb/missing.png")
  end

  def add_upvote(user)
    if self.upvote_names.nil?
      self.upvote_names = Array.new
    end
    if ! self.upvote_names.include? user.username
      self.upvote_names.push user.username
    end

    save
  end

  def remove_upvote(user)
    if not self.upvote_names.nil?
      self.upvote_names.delete user.username
    end

    save
  end

  def how_many_upvotes
    if self.upvote_names.nil?
      return 0
    else
      self.upvote_names.length
    end
  end

  def upvoted?(user)
    return false if user.nil?

    if self.upvote_names.nil?
      return false
    else
      self.upvote_names.include? user.username
    end
  end

  def comment(message, user)
    Comment.create(event: self, message: message, authored_by: user)
  end

  def comment_count
    Comment.where(event_id: id).count
  end

  def root_comments
    self.comments.where(:parent => nil)
  end
end
