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
    if not event.upvote_names.nil?
      event.upvote_count = event.upvote_names.size
    end
  end

  after_save do |event|
    return if event.reminders.blank?
    event.reminders.each do |r|
      r.refresh_send_at
      r.save
    end
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
        tz = TZInfo::Timezone.get('America/New_York')
        return tz.local_to_utc(local_datetime)
      end
    else
      return datetime
    end
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

  def add_upvote(username)
    if self.upvote_names.nil?
      self.upvote_names = Array.new
    end
    if ! self.upvote_names.include? username
      self.upvote_names.push username
    end
  end

  def remove_upvote(username)
    if not self.upvote_names.nil?
      self.upvote_names.delete username
    end
  end

  def how_many_upvotes
    if self.upvote_names.nil?
      return 0
    else
      self.upvote_names.length
    end
  end

  def have_i_upvoted(username)
    if self.upvote_names.nil?
      return false
    else
      self.upvote_names.include? username
    end
  end

  def relative_date(zone_offset)
    if self.is_all_day == true || self.time_format == "recurring" || self.time_format == "tv_show"
      return self.local_date.to_date
    else
      return (self.datetime - zone_offset.minutes).beginning_of_day.to_date
    end
  end

  def self.get_starting_events(datetime, zone_offset, country, subkasts, minimum, eventsPerDay, topRanked)
    listEvents = self.get_starting_events_query(datetime, zone_offset, country, subkasts, minimum, eventsPerDay)
    topEvents = self.top_ranked(topRanked, datetime, datetime + 7.days, zone_offset, country, subkasts)
    events = listEvents.concat topEvents
    events.uniq!
    events.sort_by! { |event| - (event.upvote_names.nil? ? 0 : event.upvote_names.size) }
    return events
  end

  def self.get_events_after_date(datetime, zone_offset, country, subkasts, howMany=0)
    self.get_enough_events_from_day(datetime, zone_offset, country, subkasts, howMany, 3)
  end

  def self.get_events_by_date(startDatetime, zone_offset, country, subkasts, howMany=0, skip=0)
    endDatetime = startDatetime + 1.day - 1.second
    self.get_events_by_range(startDatetime, endDatetime, zone_offset, country, subkasts, howMany, skip)
  end

  def self.count_events_by_date(datetime, zone_offset, country, subkasts)
    Array(self.get_events_by_date(datetime, zone_offset, country, subkasts)).size
  end

  def self.top_ranked(howMany, startDatetime, endDatetime, zone_offset, country, subkasts)
    self.get_events_by_range(startDatetime, endDatetime, zone_offset, country, subkasts, howMany)
  end

  def self.get_enough_events_from_day(datetime, zone_offset, country, subkasts, minimum, eventsPerDay)
    date = (datetime - zone_offset.minutes).beginning_of_day

    possible_events = self.any_of(
      { is_all_day: false, time_format: '', :datetime.gte => datetime, location_type: 'national', country: country },
      { is_all_day: false, time_format: '', :datetime.gte => datetime, location_type: 'international' },
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'national', country: country },
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'international' },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'national', country: country },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'international' },
      { is_all_day: true, :local_date.gte => date, location_type: 'national', country: country },
      { is_all_day: true, :local_date.gte => date, location_type: 'international' }
    ).any_in({subkast: subkasts}).to_a

    sorted_possible_events = possible_events.sort_by { |event| - (event.upvote_count.nil? ? 0 : event.upvote_count) }
    massage_events(sorted_possible_events, possible_events, zone_offset, eventsPerDay, minimum)
  end

  def self.get_starting_events_query(datetime, zone_offset, country, subkasts, minimum, eventsPerDay)
    date = (datetime - zone_offset.minutes).beginning_of_day

    possible_events = self.any_of(
      { is_all_day: false, time_format: '', :datetime.gte => datetime, location_type: 'national', country: country},
      { is_all_day: false, time_format: '', :datetime.gte => datetime, location_type: 'international'},
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'national', country: country } ,
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'international'},
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'national', country: country },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'international'},
      { is_all_day: true, :local_date.gte => date, location_type: 'national', country: country},
      { is_all_day: true, :local_date.gte => date, location_type: 'international'},
    ).any_in({subkast: subkasts}).to_a

    sorted_possible_events = possible_events.sort_by { |event| - (event.upvote_count.nil? ? 0 : event.upvote_count) }
    massage_events(sorted_possible_events, possible_events, zone_offset, eventsPerDay, minimum)
  end

  def self.massage_events(sorted_possible_events, possible_events, zone_offset, eventsPerDay, minimum)
    events = []

    dates = possible_events.collect { |event| event.relative_date(zone_offset) }
    dates.sort_by! { |date| date }
    dates = dates.uniq

    each_day_min_events = 0
    dates.each do |date|
      eventsOnDate = sorted_possible_events.select { |event| event.relative_date(zone_offset) == date }
      events.concat eventsOnDate
      each_day_min_events += eventsOnDate.take(eventsPerDay).size
      break if each_day_min_events >= minimum
    end

    return events
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
