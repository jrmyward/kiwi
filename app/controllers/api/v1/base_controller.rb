module Api
  module V1
    class BaseController < ApiController
      version 1

      def event_not_found
        {
          error: 'event_not_found',
          error_description: 'Could not find the event.'
        }
      end
    end
  end
end
