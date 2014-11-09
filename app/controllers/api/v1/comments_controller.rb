module Api
  module V1
    class CommentsController < BaseController
      def index
        event = Event.where(id: params[:event_id]).first
        @user = api_current_user

        error! :event_not_found, metadata: event_not_found if event.nil?

        comments = decorate(event.root_comments)

        expose(comments)
      end

      def create

      end

      def destroy

      end

      private

      def decorate(comments)
        comments.map do |comment|
          json = {
            id: comment.id,
            message: comment.message,
            by: comment.authored_by.username,
            upvote_count: comment.upvote_count,
            downvote_count: comment.downvote_count
          }

          json[:upvoted] = comment.have_i_upvoted(@user) if @user.present?
          json[:downvoted] = comment.have_i_downvoted(@user) if @user.present?
          json[:replies] = decorate(Comment.where(parent_id: comment.id))

          json
        end
      end
    end
  end
end
