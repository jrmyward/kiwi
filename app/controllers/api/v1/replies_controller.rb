module Api
  module V1
    class RepliesController < CommentsController
      def create
        error! :unauthenticated if api_current_user.nil?

        comment = Comment.where(id: params[:comment_id]).first
        error! :not_found, metadata: comment_not_found if comment.nil?

        reply = comment.reply(params['message'], api_current_user)
        reply.add_upvote(api_current_user)

        CommentMailer.send_notifications(reply)
        exposes(decorate_one(reply))
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
