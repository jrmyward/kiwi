module Api
  module V1
    class RemindersController < BaseController
      def index
        event = Event.find(params[:event_id])
        user = api_current_user

        intervals = ['15m', '1h', '4h', '1d']
        reminders = event.reminders_for_user(user).map(&:time_to_event)

        intervals = intervals & reminders
        intervals = intervals.map { |i| { interval: i } }

        exposes(intervals)
      end
    end
  end
end
