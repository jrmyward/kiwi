require 'spec_helper'

describe Comment do
  before :all do
    @comment = build :comment
  end

  describe "Creating and Setting Comments" do

    it "should create comments" do
      @comment.should be_kind_of Comment
      @comment.event.should be_kind_of Event
      @comment.status.should == "active"
    end

    it "should have an author" do
      @comment.authored_by.should be_kind_of User
    end

    it "should create trees of comments" do
      root = @comment
      root.new_comment(create(:comment))
      root.new_comment(create(:comment))
      root.children.length.should == 2
    end

  end

  describe "Setting Comment Statuses" do

    it "should have a flagged status" do
      comment = create :flagged_comment
      comment.status.should == "flagged"
    end

    it "should be deletable" do
      comment = create :deleted_comment
      comment.status.should == "deleted"
    end

    it "should be hidable" do
      comment = create :muted_comment
      comment.status.should == "muted"
    end

  end

  describe "Comment Voting" do
    let(:u1) { create :user }

    it "should upvote comment" do
      @comment.add_upvote(u1)
      expect(@comment).to be_upvoted_by(u1)
      @comment.remove_upvote(u1)
      expect(@comment).not_to be_upvoted_by(u1)
    end

    it "should downvote comment" do
      @comment.add_downvote(u1)
      expect(@comment).to be_downvoted_by(u1)
      @comment.remove_downvote(u1)
      expect(@comment).not_to be_downvoted_by(u1)
    end

    it "was previously upvoted, it should now downvote comment" do
      @comment.add_upvote(u1)
      expect(@comment).to be_upvoted_by(u1)
      @comment.remove_upvote(u1)
      @comment.add_downvote(u1)
      expect(@comment).not_to be_upvoted_by(u1)
      expect(@comment).to be_downvoted_by(u1)
    end

    it "was previously downvoted, it should now upvote comment" do
      @comment.add_downvote(u1)
      expect(@comment).to be_downvoted_by(u1)
      @comment.remove_downvote(u1)
      @comment.add_upvote(u1)
      expect(@comment).not_to be_downvoted_by(u1)
      expect(@comment).to be_upvoted_by(u1)
    end
  end
end
