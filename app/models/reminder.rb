class Reminder
  include Mongoid::Document
  include Mongoid::Timestamps
  field :send_at,  :type => Time
  field :status, :type => String 
  field :time_to_event, :type => String
  field :recipient_time_zone, :type => String
  belongs_to :user
  belongs_to :event

  before_create do |reminder|
    reminder.refresh_send_at
    reminder.status = "PENDING"
  end

  def refresh_send_at
    event_time = event.get_utc_datetime(recipient_time_zone)
    self.send_at = event_time - 15.minutes if time_to_event == '15m'
    self.send_at = event_time - 1.hour if time_to_event == '1h'
    self.send_at = event_time - 4.hour if time_to_event == '4h'
    self.send_at = event_time - 1.day if time_to_event == '1d'
  end

  def self.send_reminders
    #TODO stuff here
    # test business logic here to see if status = PENDING, and the time is right
    logger.info "SEND REMINDERS!"
    ReminderMailer.welcome.deliver!
  end
end
