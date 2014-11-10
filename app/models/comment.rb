require './lib/kiwi_ordering'

class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Traversal
  include KiwiOrdering

  belongs_to :event
  belongs_to :deleted_by, class_name: 'User'
  belongs_to :muted_by, class_name: 'User'
  belongs_to :authored_by, class_name: 'User'

  has_and_belongs_to_many :flagged_by, class_name: 'User', inverse_of: nil
  has_and_belongs_to_many :upvoted_by, class_name: 'User', inverse_of: nil

  field :message, type: String
  field :upvotes, type: Integer
  field :downvotes, type: Integer
  field :upvote_names, type: Array
  field :downvote_names, type: Array

  before_save do |comment|
    comment.upvotes = 0
    comment.downvotes = 0
    if not comment.upvote_names.nil?
      comment.upvotes = comment.upvote_names.size
    end
    if not comment.downvote_names.nil?
      comment.downvotes = comment.downvote_names.size
    end
  end

  after_create do |comment|
    HipChatNotification.new_comment(comment)
  end

  def status
    return 'deleted' if deleted_by.kind_of? User
    return 'muted' if muted_by.kind_of? User
    return 'flagged' if flagged_by.size > 0
    'active'
  end

  def new_comment(comment)
    comment.parent = self
  end

  def reply(message, user)
    Comment.create(event: event, message: message, authored_by: user, parent: self)
  end

  def parent_author
    parent.authored_by
  end

  def reply?
    parent.present?
  end

  def event_owner
    User.where(username: event.user).first
  end

  def setup_params(params)
    self.message = params[:message]
    self.parent_id = params[:parent_id]
    self.event_id = params[:event_id]
  end

  def upvoted?(user)
    username = user.username
    if self.upvote_names.nil?
      return false
    else
      self.upvote_names.include? username
    end
  end

  def downvoted?(user)
    username = user.username
    if self.downvote_names.nil?
      return false
    else
      self.downvote_names.include? username
    end
  end

  def upvote_count
    upvote_names.present? ? upvote_names.size : 0
  end

  def add_upvote(user)
    username = user.username
    if self.upvote_names.nil?
      self.upvote_names = Array.new
    end
    if ! self.upvote_names.include? username
      self.upvote_names.push username
    end

    save

    remove_downvote(user)
  end

  def remove_upvote(user)
    username = user.username
    if not self.upvote_names.nil?
      self.upvote_names.delete username
    end

    save
  end

  def downvote_count
    downvote_names.present? ? downvote_names.size : 0
  end

  def add_downvote(user)
    username = user.username
    if self.downvote_names.nil?
      self.downvote_names = Array.new
    end
    if ! self.downvote_names.include? username
      self.downvote_names.push username
    end

    save
  end

  def remove_downvote(user)
    username = user.username
    if not self.downvote_names.nil?
      self.downvote_names.delete username
    end

    save
  end

  def vote(upvoted, downvoted, username)
    if ( upvoted )
        self.remove_downvote(username)
        self.add_upvote(username)
    elsif ( downvoted )
        self.remove_upvote(username)
        self.add_downvote(username)
    else
        self.remove_downvote(username)
        self.remove_upvote(username)
    end
  end

  def comment_text
    parent_id.present? ? "replied to one of your comments" : "commented on one of your events"
  end

end
