module Api
  module V1
    class UpvoteController < BaseController
      RocketPants::Errors.register! :already_upvoted, http_status: :unprocessable_entity
      RocketPants::Errors.register! :not_upvoted, http_status: :unprocessable_entity

      before_action :set_event

      def index
        upvote_expose
      end

      def create
        error! :already_upvoted, metadata: { error_message: 'You have already upvoted for this event once.' } if @event.upvoted?(api_current_user)

        @event.add_upvote(api_current_user)
        @event.save

        upvote_expose
      end

      def destroy
        error! :not_upvoted, metadata: { error_message: 'You have not upvoted on this event previously.' } unless @event.upvoted?(api_current_user)

        @event.remove_upvote(api_current_user)
        @event.save

        upvote_expose
      end

      private

      def set_event
        @event = Event.find(params[:event_id])
      end

      def upvote_expose
        expose({
          upvote_count: @event.how_many_upvotes,
          upvoted: @event.upvoted?(api_current_user)
        })
      end
    end
  end
end
