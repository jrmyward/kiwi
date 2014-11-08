module Api
  module V1
    class RemindersController < BaseController
      def index
        event = Event.where(id: params[:event_id]).first
        error! :event_not_found, metadata: event_not_found if event.nil?

        user = api_current_user
        error! :unauthenticated if user.nil?

        intervals = ['15m', '1h', '4h', '1d']
        reminders = event.reminders_for_user(user).map(&:time_to_event)

        intervals = intervals & reminders
        intervals = intervals.map { |i| { interval: i } }

        exposes(intervals)
      end

      private

      def event_not_found
        {
          error: 'event_not_found',
          error_description: 'Could not find the event to lookup reminders.'
        }
      end
    end
  end
end
