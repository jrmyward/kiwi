module Api
  module V1
    class CommentsController < BaseController
      def index
        event = Event.where(id: params[:event_id]).first

        error! :event_not_found, metadata: event_not_found if event.nil?

        comments = decorate(event.root_comments)

        expose(comments)
      end

      def create
        event = Event.where(id: params[:event_id]).first

        error! :event_not_found, metadata: event_not_found if event.nil?
        error! :unauthenticated if api_current_user.nil?

        event.comment(params['message'], api_current_user)

        comments = decorate(event.root_comments)

        expose(comments)
      end

      def destroy
        authenticate!

        comment = Comment.where(id: params[:id]).first

        error! :not_found if comment.nil?

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
    end
  end
end
