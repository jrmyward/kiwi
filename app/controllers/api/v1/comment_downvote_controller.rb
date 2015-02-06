module Api
  module V1
    class CommentDownvoteController < CommentsController
      def create
        authenticate!

        comment = Comment.where(id: params[:comment_id]).first

        error! :comment_not_found, metadata: comment_not_found if comment.nil?
        error! :comment_already_downvoted, metadata: comment_already_downvoted if comment.downvoted_by?(api_current_user)

        comment.add_downvote(api_current_user)

        exposes(decorate_one(comment))
      end

      def destroy
        authenticate!

        comment = Comment.where(id: params[:comment_id]).first

        error! :comment_not_found, metadata: comment_not_found if comment.nil?
        error! :comment_not_downvoted, metadata: comment_not_downvoted unless comment.downvoted_by?(api_current_user)

        comment.remove_downvote(api_current_user)

        exposes(decorate_one(comment))
      end

      def comment_already_downvoted
        {
          error: 'comment_already_downvoted',
          error_description: 'User has already downvoted on this comment and cannot downvote twice.'
        }
      end

      def comment_not_downvoted
        {
          error: 'comment_not_downvoted',
          error_description: 'User has not downvoted this comment so the downvote can\'t be removed.'
        }
      end

      def comment_not_found
        {
          error: 'comment_not_found',
          error_description: 'Could not find the comment to upvote.'
        }
      end
    end
  end
end
