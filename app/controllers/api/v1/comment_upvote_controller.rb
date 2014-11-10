module Api
  module V1
    class CommentUpvoteController < CommentsController
      def create
        authenticate!

        comment = Comment.where(id: params[:comment_id]).first

        error! :comment_not_found, metadata: comment_not_found if comment.nil?
        error! :comment_already_upvoted, metadata: comment_already_upvoted if comment.upvoted?(api_current_user)

        comment.add_upvote(api_current_user)

        exposes(decorate_one(comment))
      end

      def destroy
        authenticate!

        comment = Comment.where(id: params[:comment_id]).first

        error! :comment_not_found, metadata: comment_not_found if comment.nil?
        error! :comment_not_upvoted, metadata: comment_not_upvoted unless comment.upvoted?(api_current_user)

        comment.remove_upvote(api_current_user)

        exposes(decorate_one(comment))
      end

      def comment_not_found
        {
          error: 'comment_not_found',
          error_description: 'Could not find the comment to upvote.'
        }
      end

      def comment_already_upvoted
        {
          error: 'comment_already_upvoted',
          error_description: 'User has already upvoted on this comment and cannot upvote twice.'
        }
      end

      def comment_not_upvoted
        {
          error: 'comment_not_upvoted',
          error_description: 'User has not upvoted this comment so the downvote can\'t be removed.'
        }
      end
    end
  end
end
