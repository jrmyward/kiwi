class CommentMailer < ActionMailer::Base
  default from: "Forekast <hello@forekast.com>"

  def send_notifications(comment)
    reply_notice(comment).deliver! if comment.reply? and should_send_comment_reply?(comment)
    comment_notice(comment).deliver! if should_send_comment_notice?(comment)
  end

  def should_send_comment_reply?(comment)
    comment.parent_author.receive_comment_notifications and comment.parent_author != comment.authored_by
  end

  def should_send_comment_notice?(comment)
    comment.event_owner.receive_comment_notifications and comment.authored_by != comment.event_owner and
    (comment.parent.nil? or comment.parent.authored_by != comment.event_owner)
  end

  def comment_notice(comment)
    @comment = comment
    mail(to: comment.event_owner.email, subject: "#{comment.authored_by.username} commented on your event", template_name: "comment_notice")
  end

  def reply_notice(comment)
    @comment = comment
    mail(to: comment.parent_author.email, subject: "#{comment.authored_by.username} replied to your comment", template_name: "reply_notice")
  end
end
