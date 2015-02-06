module Api
  module V1
    class ReminderIntervalsController < BaseController
      def index
        intervals = ['15m', '1h', '4h', '1d']
        exposes(intervals.map { |i| { interval: i} })
      end
    end
  end
end
