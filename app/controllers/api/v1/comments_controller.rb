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

        json[:upvoted] = comment.have_i_upvoted(api_current_user) if api_current_user.present?
        json[:downvoted] = comment.have_i_downvoted(api_current_user) if api_current_user.present?
        json[:replies] = decorate(Comment.where(parent_id: comment.id))

        json
      end
    end
  end
end
