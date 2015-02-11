class EventRepository
  def initialize(time_zone, country, subkasts = nil)
    @time_zone = time_zone.present? ? ActiveSupport::TimeZone.new(time_zone) : ActiveSupport::TimeZone.new(Event::DEFAULT_TIME_ZONE)
    @country = country
    @subkasts = subkasts || Subkast.all.map(&:code)
  end

  def events_on_date(date, skip = 0, how_many = 5)
    date = DateTime.parse(date)
    events_by_range(date, date.end_of_day, how_many, skip)
  end

  def events_from_date(date, how_many_dates, how_many_events_per_day = 3)
    date = DateTime.parse(date)
    enough_events_from_date(date, how_many_dates, how_many_events_per_day)
  end

  def count_events_on_date(date)
    date = DateTime.parse(date)
    events_by_range(date, date.end_of_day).size
  end

  def top_ranked_events(from_date, to_date, how_many_events)
    from_date = DateTime.parse(from_date)
    to_date = DateTime.parse(to_date)

    events_by_range(from_date, to_date, how_many_events)
  end

  def most_recent_events(date, how_many)
    date = DateTime.parse(date)
    utc_date = @time_zone.local_to_utc(date)

    events = Event.any_of(
      { is_all_day: false, time_format: '', :datetime.gte => utc_date, location_type: 'international' },
      { is_all_day: false, time_format: '', :datetime.gte => utc_date, location_type: 'national', country: @country },
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'international' },
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'national', country: @country },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'international' },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'national', country: @country },
      { is_all_day: true, :local_date.gte => date, location_type: 'international' },
      { is_all_day: true, :local_date.gte => date, location_type: 'national', country: @country }
    ).any_in({ subkast: @subkasts }).limit(how_many).to_a

    events
  end

  # temporary implementation for backwards compatibility
  def self.events_on_date_by_offset(datetime, zone_offset, country, subkasts, how_many, skip)
    start_date = datetime.beginning_of_day
    end_date = start_date + 1.day

    utc_start_datetime = datetime - zone_offset.minutes
    utc_end_datetime = datetime + 1.day

    events = Event.any_of(
      { is_all_day: false, time_format: '', datetime: (utc_start_datetime..utc_end_datetime), location_type: 'international' },
      { is_all_day: false, time_format: '', datetime: (utc_start_datetime..utc_end_datetime), location_type: 'national', country: country },
      { is_all_day: false, time_format: 'recurring', local_date: (start_date..end_date), location_type: 'international' },
      { is_all_day: false, time_format: 'recurring', local_date: (start_date..end_date), location_type: 'national', country: country },
      { is_all_day: false, time_format: 'tv_show', local_date: (start_date..end_date), location_type: 'international' },
      { is_all_day: false, time_format: 'tv_show', local_date: (start_date..end_date), location_type: 'national', country: country },
      { is_all_day: true, local_date: (start_date..end_date), location_type: 'international' },
      { is_all_day: true, local_date: (start_date..end_date), location_type: 'national', country: country }
    ).any_in({ subkast: subkasts }).to_a


    sortedEvents = events.sort_by { |event| event.id }.sort_by { |event| - (event.upvote_count.nil? ? 0 : event.upvote_count) }
    how_many = sortedEvents.size if how_many == 0

    return [] if skip > sortedEvents.size

    out = sortedEvents.slice(skip, how_many)

    out
  end

  private

  def events_by_range(start_date, end_date, how_many = 0, skip = 0)
    utc_start_datetime = @time_zone.local_to_utc(start_date)
    utc_end_datetime = @time_zone.local_to_utc(end_date)

    events = Event.any_of(
      { is_all_day: false, time_format: '', datetime: (utc_start_datetime..utc_end_datetime), location_type: 'international' },
      { is_all_day: false, time_format: '', datetime: (utc_start_datetime..utc_end_datetime), location_type: 'national', country: @country },
      { is_all_day: false, time_format: 'recurring', local_date: (start_date..end_date), location_type: 'international' },
      { is_all_day: false, time_format: 'recurring', local_date: (start_date..end_date), location_type: 'national', country: @country },
      { is_all_day: false, time_format: 'tv_show', local_date: (start_date..end_date), location_type: 'international' },
      { is_all_day: false, time_format: 'tv_show', local_date: (start_date..end_date), location_type: 'national', country: @country },
      { is_all_day: true, local_date: (start_date..end_date), location_type: 'international' },
      { is_all_day: true, local_date: (start_date..end_date), location_type: 'national', country: @country }
    ).any_in({ subkast: @subkasts }).to_a


    sortedEvents = events.sort do |e1, e2|
      if e1.upvote_count == e2.upvote_count
        e1.id <=> e2.id
      else
        e2.upvote_count <=> e1.upvote_count
      end
    end

    how_many = sortedEvents.size if how_many == 0

    return [] if skip > sortedEvents.size

    out = sortedEvents.slice(skip, how_many)

    out
  end

  def enough_events_from_date(date, how_many_dates, events_per_day = 3)
    datetime = @time_zone.local_to_utc(date)

    possible_events = Event.any_of(
      { is_all_day: false, time_format: '', :datetime.gte => datetime, location_type: 'national', country: @country },
      { is_all_day: false, time_format: '', :datetime.gte => datetime, location_type: 'international' },
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'national', country: @country },
      { is_all_day: false, time_format: 'recurring', :local_date.gte => date, location_type: 'international' },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'national', country: @country },
      { is_all_day: false, time_format: 'tv_show', :local_date.gte => date, location_type: 'international' },
      { is_all_day: true, :local_date.gte => date, location_type: 'national', country: @country },
      { is_all_day: true, :local_date.gte => date, location_type: 'international' }
    ).any_in({subkast: @subkasts}).to_a


    dates = possible_events.collect { |event| event.get_local_datetime(@time_zone.name).to_date }
    dates.sort_by! { |date| date }
    dates = dates.uniq

    events = []
    sorted_possible_events = possible_events.sort do |e1, e2|
      if e1.upvote_count == e2.upvote_count
        e1.id <=> e2.id
      else
        e2.upvote_count <=> e1.upvote_count
      end
    end

    dates.each do |date|
      break if how_many_dates == 0

      eventsOnDate = sorted_possible_events.select { |event| event.get_local_datetime(@time_zone.name).to_date == date }
      events.concat eventsOnDate.take(events_per_day)

      how_many_dates = how_many_dates - 1 unless eventsOnDate.empty?
    end

    return events
  end

  def get_last_date
    return Time.utc(1969) if Event.count == 0
    Event.order_by([:local_date, :desc])[0].local_date.tomorrow
  end

  def tomorrow(date)
    DateTime.parse(date).tomorrow.to_s
  end
end
