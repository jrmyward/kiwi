require 'open-uri'
require 'open_uri_redirections'
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
  field :tv_time, type: String
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

  has_many :reminders, dependent: :delete
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

  DEFAULT_TIME_ZONE = 'America/New_York'

  after_create do |event|
    HipChatNotification.new_event(event)
  end

  before_save do |event|
    event.upvote_count = 0
    if not event.upvote_names.nil?
      event.upvote_count = event.upvote_names.size
    end
  end

  def country_name
    Country.find_by(code: country).en_name
  end

  def national?
    location_type == 'national'
  end

  def international?
    location_type == 'international'
  end

  def location_string
    return 'National' if national?
    return 'Global' if international?
  end

  def location
    return 'Global' if international?
    return country_name.strip
  end

  def all_day?
    is_all_day
  end

  def recurring?
    !all_day? && time_format == 'recurring'
  end

  def tv_show?
    !all_day? && time_format == 'tv_show'
  end

  def relative?
    !all_day? && time_format.blank?
  end

  def started?(datetime, time_zone)
    datetime > get_local_datetime(time_zone)
  end

  def full_subkast
    Subkast.by_code(subkast).name
  end

  def refresh_reminders
    reminders.each do |r|
      r.refresh_send_at
      r.save
    end
  end

  def set_all_reminders_pending
    reminders.each do |reminder|
      reminder.status = Reminder::STATUS_PENDING
      reminder.save
    end
  end

  def time_changed?
    previous_changes.keys.any? { |k| %w(local_time datetime is_all_day time_format).include? k }
  end

  def name_escaped
    ActionView::Base.full_sanitizer.sanitize(name)
  end

  def reminders_for_user(user)
    reminders.where(user: user)
  end

  def get_utc_datetime(timezone)
    if is_all_day == true or time_format == 'recurring' or time_format == 'tv_show'
      tz = TZInfo::Timezone.get(timezone)

      return tz.local_to_utc(local_date.to_datetime) if is_all_day
      return tz.local_to_utc(local_datetime) if time_format == 'recurring'

      if time_format == 'tv_show'
        tz = TZInfo::Timezone.get(Event::DEFAULT_TIME_ZONE)
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

    timezone ||= Event::DEFAULT_TIME_ZONE
    tz = TZInfo::Timezone.get(timezone)

    if time_format == 'tv_show'
      tz_east = TZInfo::Timezone.get('America/New_York')
      return Time.parse(tz_east.local_to_utc(tz.utc_to_local(local_datetime)).strftime("%Y-%m-%d %H:%M:%S"))
    end

    if time_format == 'recurring'
      return local_datetime
    end

    return Time.parse(tz.utc_to_local(datetime.utc).strftime("%Y-%m-%d %H:%M:%S"))
  end

  def local_datetime
    Time.parse(local_date.to_s + " " + local_time)
  end

  def local_date_with_slashes
    local_date.strftime('%d/%m/%Y') rescue ''
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

  def pretty_datetime(timezone)
    get_local_datetime(timezone).strftime('%-d %B, %Y - %A, %l:%M %p')
  end

  def datetime_string(timezone)
    datetime = get_local_datetime(timezone)
    return datetime.strftime("%A, %b %-d#{date_suffix(datetime)} %Y, #{pretty_time(timezone)}")
  end

  def date_string(timezone)
    datetime = get_local_datetime(timezone)
    datetime.strftime("%b %-d#{date_suffix(datetime)} %Y")
  end

  def date_suffix(datetime)
    date = datetime.day

    digit = date % 10

    return 'st' if digit == 1
    return 'nd' if digit == 2
    return 'rd' if digit == 3

    'th'
  end

  def pretty_time(timezone)
    return 'All Day' if all_day?
    return tv_time if tv_show?
    return get_local_datetime(timezone).strftime('%l:%M%P').strip
  end

  def tv_time
    "#{get_local_datetime('America/New_York').strftime('%l:%M').strip}/#{(get_local_datetime('America/New_York') - 1.hour).strftime('%l:%M').strip}c"
  end

  def reminders_for_user(user)
    reminders.where(user: user)
  end

  def set_reminder(user, interval, recipient_time_zone)
    Reminder.create(event_id: id, user_id: user.id, time_to_event: interval, recipient_time_zone: recipient_time_zone)
  end

  def remove_reminder(user, interval)
    Reminder.where(event_id: id, user_id: user.id, time_to_event: interval).delete
  end

  def save_image(params)
    update_attribute(:width, params[:width])
    update_attribute(:height, params[:height])
    update_attribute(:crop_x, params[:crop_x])
    update_attribute(:crop_y, params[:crop_y])

    return image.reprocess! if params[:image].blank? && params[:url].blank?

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
        update_attribute(:image, open(url, allow_redirections: :all))
      end
    else
      update_attribute(:image, self.no_image())
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

  def rebalance_comments
    root_comments.sort { |a,b|
      b.netvotes <=> a.netvotes
    }.each_with_index do |comment, i|
      Comment.rebalance(comment, i)
    end
  end

  def self.get_events_by_range(startDatetime, endDatetime, zone_offset, country, subkasts, howMany=0, skip=0)
    startDate = (startDatetime - zone_offset.minutes).beginning_of_day
    endDate = (endDatetime - zone_offset.minutes).beginning_of_day

    events = self.any_of(
      { is_all_day: false, time_format: '', datetime: ((startDatetime)..(endDatetime)), location_type: 'international' },
      { is_all_day: false, time_format: '', datetime: (startDatetime..endDatetime), location_type: 'national', country: country },
      { is_all_day: false, time_format: 'recurring', local_date: (startDate..endDate), location_type: 'international' },
      { is_all_day: false, time_format: 'recurring', local_date: (startDate..endDate), location_type: 'national', country: country },
      { is_all_day: false, time_format: 'tv_show', local_date: (startDate..endDate), location_type: 'international' },
      { is_all_day: false, time_format: 'tv_show', local_date: (startDate..endDate), location_type: 'national', country: country },
      { is_all_day: true, local_date: (startDate..endDate), location_type: 'international' },
      { is_all_day: true, local_date: (startDate..endDate), location_type: 'national', country: country }
    ).any_in({subkast: subkasts }).to_a

    sortedEvents = events.sort_by { |event| - (event.upvote_count.nil? ? 0 : event.upvote_count) }
    howMany = sortedEvents.size if howMany == 0
    return sortedEvents.slice(skip, howMany)
  end

  def self.get_last_date
    self.order_by([:local_date, :desc])[0].local_date
  end

  def comment_count
    Comment.where(event_id: id).count
  end

  def root_comments
    self.comments.where(:parent => nil)
  end
end
