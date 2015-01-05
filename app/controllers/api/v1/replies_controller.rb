module Api
  module V1
    class RepliesController < CommentsController
      def create
        error! :unauthenticated if api_current_user.nil?

        comment = Comment.find_by(id: params[:comment_id])
        error! :not_found, metadata: comment_not_found if comment.nil?

        reply = comment.reply(params['message'], api_current_user)

        CommentMailer.send_notifications(comment)
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
