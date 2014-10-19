class EventRepository
  def initialize(time_zone, country, subkasts)
    @time_zone = ActiveSupport::TimeZone.new(time_zone)
    @country = country
    @subkasts = subkasts
  end

  def events_on_date(date, how_many = 0, skip = 0)
    date = DateTime.parse(date)
    events_by_range(date, date.end_of_day, how_many, skip)
  end

  def events_from_date(date, how_many_dates, how_many_events_per_day = 5)
    count = 0
    events = []
    dates_with_events = []

    while dates_with_events.count < how_many_dates
      break if DateTime.parse(date) == get_last_date
      break if count > 30
      new_events = events_on_date(date, how_many_events_per_day).to_a
      events = events + new_events

      dates_with_events << date unless new_events.empty?
      date = tomorrow(date)
      count = count + 1
    end

    events
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

    sortedEvents = events.sort_by { |event| - (event.upvote_count.nil? ? 0 : event.upvote_count) }
    how_many = sortedEvents.size if how_many == 0

    sortedEvents.slice(skip, how_many)
  end

  def get_last_date
    Event.order_by([:local_date, :desc])[0].local_date
  end

  def tomorrow(date)
    DateTime.parse(date).tomorrow.to_s
  end
end
