module Api
  module V1
    class RemindersController < BaseController
      def index
        event = Event.where(id: params[:event_id]).first
        error! :event_not_found, metadata: event_not_found if event.nil?

        user = api_current_user
        error! :unauthenticated if user.nil?

        exposes intervals_on_event_for_user(event, user)
      end

      def create
        event = Event.where(id: params[:event_id]).first
        user = api_current_user

        error! :unauthenticated if user.nil?
        error! :event_not_found, metadata: event_not_found if event.nil?
        error! :invalid_reminder_interval, metadata: invalid_reminder_interval unless valid_intervals.include?(params['interval'])

        existing_reminders = event.reminders_for_user(user).map(&:time_to_event)
        error! :reminder_already_set, metadata: reminder_already_set if existing_reminders.include?(params['interval'])

        event.set_reminder(user, params['interval'], params['recipient_time_zone'])

        exposes intervals_on_event_for_user(event, user)
      end

      def destroy
        interval = params['id']
        user = api_current_user
        event = Event.where(id: params[:event_id]).first

        error! :unauthenticated if user.nil?
        error! :event_not_found, metadata: event_not_found if event.nil?

        reminders = event.reminders_for_user(user).map(&:time_to_event)

        error! :not_found, metadata: missing_reminder unless reminders.include?(interval)

        event.remove_reminder(user, interval)
      end

      private

      def invalid_reminder_interval
        {
          error: 'invalid_reminder_interval',
          error_description: 'Provided reminder interval does not exist.'
        }
      end

      def reminder_already_set
        {
          error: 'reminder_already_set',
          error_description: 'A reminder at this interval is already set for this event.'
        }
      end

      def missing_reminder
        {
          error: 'missing_reminder',
          error_description: 'Event does not have this reminder interval set.'
        }
      end

      def valid_intervals
        ['15m', '1h', '4h', '1d']
      end

      def interval_sorting_map(i)
        return 0 if i == '15m'
        return 1 if i == '1h'
        return 2 if i == '4h'
        return 3 if i == '1d'
      end

      def intervals_on_event_for_user(event, user)
        reminders = event.reminders_for_user(user).sort_by { |r| interval_sorting_map(r.time_to_event) }

        reminders.map { |r| { interval: r.time_to_event, recipient_time_zone: r.recipient_time_zone } }
      end
    end
  end
end
