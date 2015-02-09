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

  def today(date)
    ActiveSupport::TimeZone.new(@time_zone).utc_to_local(DateTime.now.utc).day == date.day ? 'Today,' : ''
  end
end
