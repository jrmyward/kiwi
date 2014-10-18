class HipChatNotification
  def self.new_user(user)
    return unless self.is_properly_configured?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    message = "New user joined Forekast: #{user.name} - #{user.email} - #{user.username}"
    begin
      client[CONFIG['hipchat_notifications_room']].send('kiwibot', message, :color => 'green')
    rescue
      Rails.logger.error "Error in the hipchat API while signing up user: #{user.email}."
    end
  end

  def self.new_event(event)
    return unless self.is_properly_configured?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    uri = "http://forekast.com/#events/show/#{event.id}"
    message = "New event posted: #{event.name} - <a href='#{uri}'>#{uri}</a>"
    begin
      client[CONFIG['hipchat_notifications_room']].send('kiwibot', message, :color => 'yellow')
    rescue
      Rails.logger.error "Error in the hipchat API while creating an event: #{event.name}"
    end
  end

  def self.new_comment(comment)
    return unless self.is_properly_configured?
    client = HipChat::Client.new(CONFIG['hipchat_api_token'])
    uri = "http://forekast.com/#events/show/#{comment.event.id}."

    if comment.message.size > 30
      comment_message = "#{comment.message[0..29]}..."
    else
      comment_message = comment.message
    end

    message = "New comment posted on event (#{comment.event.name}) - <a href='#{uri}'>#{uri}</a> by #{comment.authored_by.username}: \"#{comment_message}\""
    begin
      client[CONFIG['hipchat_comments_notifications_room']].send('kiwibot', message, :color => 'purple')
    rescue
      Rails.logger.error "Error in the hipchat API while trying to post a comment to event #{comment.event.name}."
    end
  end

  def self.is_properly_configured?
    return false unless CONFIG['hipchat_notifications_room'].present?
    return false unless CONFIG['hipchat_comments_notifications_room'].present?
    return false unless CONFIG['hipchat_api_token'].present?
    return false if Rails.env != 'production'
    true
  end
end
