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

        resp = events.map do |event|
          json = {}

          json['name'] = event.name
          json['subkast'] = event.subkast
          json['location_type'] = event.location_type
          json['country'] = event.country if event.national?
          json['date'] = event.local_date if event.all_day?
          json['datetime'] = event.get_assumed_time.strftime('%Y-%m-%dT%H:%M:%S') unless event.all_day?
          json['all_day'] = true if event.all_day?
          json['recurring'] = true if event.recurring?
          json['tv_show'] = true if event.tv_show?
          json['relative'] = true if event.relative?
          json['added_by'] = event.user
          json['description'] = event.description
          json['upvotes_url'] = api_event_upvote_path(1, event.id)
          json['comments_url'] = api_event_comments_path(1, event.id)
          json['reminders_url'] = api_event_reminders_path(1, event.id)

          json
        end

        exposes(resp)
      end

      def create

      end

      def update

      end

      def destroy

      end
    end
  end
end
