module Api
  module V1
    class EventsController < BaseController
      def index
        repo = EventRepository.new(params[:time_zone], params[:country])

        if params[:on_date]
          events = repo.events_on_date(params[:on_date])
        elsif params[:after_date]
          events = repo.events_from_date(params[:after_date], 7)
        end

        resp = events.map { |event| decorate_one(event) }

        exposes(resp)
      end

      def create
        authenticate!

        event = Event.new(event_params)
        event.save
        exposes(decorate_one(event))
      end

      def update
        authenticate!

        event = Event.where(id: params[:id]).first

        error! :not_found if event.nil?
        error! :forbidden unless Ability.new(api_current_user).can? :update, event

        event.update(event_params)

        exposes(decorate_one(event))
      end

      def destroy
        authenticate!

        event = Event.where(id: params[:id]).first

        error! :not_found if event.nil?
        error! :forbidden unless Ability.new(api_current_user).can? :destroy, event

        event.destroy
      end

      private

      def event_params
        json = {}

        json[:name] = params[:name]
        json[:subkast] = params[:subkast]
        json[:country] = params[:country]
        json[:is_all_day] = params[:all_day]

        json[:location_type] = 'international' unless params[:country].present?
        json[:location_type] = 'national' if params[:country].present?

        json[:local_date] = DateTime.parse(params[:date]).to_date
        json[:local_time] = params[:time]

        if params[:time_zone].present?
          datetime = DateTime.parse("#{params[:date]} #{params[:time]}")
          json[:datetime] = ActiveSupport::TimeZone.new(params[:time_zone]).local_to_utc(datetime)
        end

        json[:time_format] = 'recurring' if params[:recurring].present?
        json[:time_format] = 'tv_show' if params[:eastern_tv_show].present?

        json[:description] = params[:description]

        json
      end

      def decorate_one(event)
        json = {}

        json['name'] = event.name
        json['subkast'] = event.subkast
        json['international'] = true if event.international?
        json['country'] = event.country if event.national?
        json['date'] = event.local_date if event.all_day?
        json['datetime'] = event.get_assumed_time.strftime('%Y-%m-%dT%H:%M:%S') unless event.all_day?
        json['all_day'] = true if event.all_day?
        json['recurring'] = true if event.recurring?
        json['eastern_tv_show'] = true if event.tv_show?
        json['relative'] = true if event.relative?
        json['added_by'] = event.user
        json['description'] = event.description
        json['upvotes_url'] = api_event_upvote_path(1, event.id)
        json['comments_url'] = api_event_comments_path(1, event.id)
        json['reminders_url'] = api_event_reminders_path(1, event.id)

        json
      end
    end
  end
end
