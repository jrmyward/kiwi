module Api
  module V1
    class CommentsController < BaseController
      before_action :get_event, only: [:index, :create]
      def index
        error! :event_not_found, metadata: event_not_found if @event.nil?
        expose(decorate(@event.root_comments))
      end

      def create
        error! :event_not_found, metadata: event_not_found if @event.nil?
        error! :unauthenticated if api_current_user.nil?

        @event.comment(params['message'], api_current_user)
        expose(decorate(@event.root_comments))
      end

      def destroy
        authenticate!
        comment = Comment.find_by(id: params[:id])

        error! :not_found if comment.nil?
        error! :forbidden unless Ability.new(api_current_user).can? :destroy, comment
        comment.delete(api_current_user)
      end

      protected

      def decorate(comments)
        comments.map do |comment|
          decorate_one(comment)
        end
      end

      def decorate_one(comment)
        json = {
          id: comment.id,
          message: comment.message,
          by: comment.authored_by.username,
          upvote_count: comment.upvote_count,
          downvote_count: comment.downvote_count
        }

        json[:upvoted] = comment.upvoted_by?(api_current_user) if api_current_user.present?
        json[:downvoted] = comment.downvoted_by?(api_current_user) if api_current_user.present?
        json[:replies] = decorate(Comment.where(parent_id: comment.id))

        json
      end

      private

      def get_event
        @event = Event.find_by(id: params[:event_id])
      end

    end
  end
end
