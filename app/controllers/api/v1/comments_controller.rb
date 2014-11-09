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

        if params['reply_to'].present?
          comment = Comment.where(id: params['reply_to']).first

          error! :comment_not_found, metadata: comment_not_found if comment.nil?

          comment.reply(params['message'], api_current_user)
        else
          event.comment(params['message'], api_current_user)
        end

        comments = decorate(event.root_comments)

        expose(comments)
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

          json[:upvoted] = comment.have_i_upvoted(api_current_user) if api_current_user.present?
          json[:downvoted] = comment.have_i_downvoted(api_current_user) if api_current_user.present?
          json[:replies] = decorate(Comment.where(parent_id: comment.id))

          json
        end
      end

      def comment_not_found
        {
          error: 'comment_not_found',
          error_description: 'Could not find the comment to reply to.'
        }
      end
    end
  end
end
