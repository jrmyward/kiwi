module ApplicationHelper
  def md(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    markdown.render(text).html_safe
  end

  def have_i_comment_upvoted? comment
    comment.upvoted_by? current_user
  end

  def have_i_comment_downvoted? comment
    comment.downvoted_by? current_user
  end

  def comment_netvotes comment
    net = comment.upvote_count - comment.downvote_count
    return 0 if net < 0
    return net
  end

  def delete_event_text
    "(Delete #{(current_user == @event.user) ? 'my' : ''} event)"
  end
end
