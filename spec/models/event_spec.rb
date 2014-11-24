require 'spec_helper'
require 'date'

describe Event do
  before (:each) do
    Timecop.freeze(Time.local(2014, 1, 24, 12, 00, 00))
  end

  after (:each) do
    Timecop.return
  end

  describe 'upvoting' do
    let(:event) { create :event }
    let(:user) { create :user }

    it 'add an upvote to the event' do
      event.add_upvote(user)

      expect(event).to be_upvoted(user)
      expect(event.upvote_count).to eq 1
    end

    it 'removes the upvote on the event' do
      event.add_upvote(user)
      event.remove_upvote(user)

      expect(event).not_to be_upvoted(user)
      expect(event.upvote_count).to eq 0
    end

    it 'does not double add upvote' do
      event.add_upvote(user)
      event.add_upvote(user)

      expect(event).to be_upvoted(user)
      expect(event.upvote_count).to eq 1
    end

    it 'does not double remove upvote' do
      event.add_upvote(user)
      event.remove_upvote(user)
      event.remove_upvote(user)

      expect(event).not_to be_upvoted(user)
      expect(event.upvote_count).to eq 0
    end
  end

  describe 'datetime getters' do
    let(:all_day_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, is_all_day: true }
    let(:relative_time_event) { create :event, datetime: Time.utc(2014, 1, 24, 3, 0, 0) }
    let(:tv_show_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, local_time: '6:00 PM', time_format: 'tv_show' }
    let(:recurring_time_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, local_time: '6:00 PM', time_format: 'recurring' }

    describe 'get utc datetime' do
      it 'should be able to get the utc datetime of an all day event' do
        all_day_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 5, 0, 0)
      end

      it 'should be able to get the utc datetime of a normal time format event' do
        relative_time_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 3, 0, 0)
      end

      it 'should be able to get the utc datetime of a eastern time tv show event' do
        tv_show_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 23, 0, 0)
      end

      it 'should be able to get the utc datetime of a recurring time zone event' do
        recurring_time_event.get_utc_datetime('America/New_York').should == Time.utc(2014, 1, 24, 23, 0, 0)
      end
    end

    describe 'get local datetime' do
      it 'should be able to get the local datetime of an all day event' do
        all_day_event.get_local_datetime('America/New_York').should == Time.local(2014, 1, 24, 0, 0, 0)
      end

      it 'should be able to get the local datetime of a normal time format event' do
        relative_time_event.get_local_datetime('America/New_York').should == Time.local(2014, 1, 23, 22, 0, 0)
      end

      it 'should be able to get the local datetime of an eastern time tv show event' do
        tv_show_event.get_local_datetime("America/Los_Angeles").should == Time.local(2014, 1, 24, 15, 0, 0)
      end

      it 'should be able to get the local datetime of a recurring time zone event' do
        recurring_time_event.get_local_datetime('America/New_York').should == Time.local(2014, 1, 24, 18, 0, 0)
      end
    end
  end

  context 'getting reminders' do
    let(:event) { create :event }
    let(:user) { create :user }

    before(:each) do
      create :reminder, :one_h_before, event: event, user: user
      create :reminder, :four_h_before, event: event, user: user
    end

    it 'should be able to get the time indicators of all reminders on this event for a particular user' do
      event.reminders_for_user(user).size.should == 2
      event.reminders_for_user(user).first.should be_kind_of Reminder
    end
  end

  describe "comment" do
    before(:each) do
      @event = build :event
      @comment1 = build :comment
      @comment2 = build :comment
      @comment1.event = @event
      @comment2.event = @event
      @event.save
      @comment1.save
      @comment2.save
    end

    it "should be able to get the root comments" do
      @event.root_comments.size.should == 2
    end

    it 'should get comment count' do
      c = create :comment
      create :comment, :event => c.event

      c.event.comment_count.should == 2
    end
  end
end
