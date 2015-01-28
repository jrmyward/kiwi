module ApplicationHelper
  def md(text)
    markdown = Redcarpet::Markdown.new(KiwiRenderer, autolink: true)
    markdown.render(text).html_safe
  end

  def have_i_comment_upvoted? comment
    comment.upvoted_by? current_user
  end

  def have_i_comment_downvoted? comment
    comment.downvoted_by? current_user
  end

  def comment_netvotes comment
    comment.netvotes
  end

  def delete_event_text
    "(Delete #{(current_user == @event.user) ? 'my' : ''} event)"
  end

  def today(date)
    Date.today.day == date.day ? 'Today,' : ''
  end
end
