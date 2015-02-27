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

    it 'handles a nil user gracefully' do
      expect(event).not_to be_upvoted(nil)
    end
  end

  describe 'checking when its started' do
    let(:all_day) { create :event, :all_day, name: 'E1', local_date: 'Jan 15, 2015' }
    let(:relative) { create :event, name: 'E2', datetime: DateTime.new(2015, 1, 20, 12, 0, 0) }
    let(:recurring) { create :event, :recurring, name: 'E3', local_date: 'Jan 15, 2015', local_time: '3:00 PM' }
    let(:tv_show) { create :event, :tv_show, name: 'E4', local_date: 'Jan 15, 2015', local_time: '6:00 PM' }

    before(:each) do
      Time.zone = ActiveSupport::TimeZone['America/New_York']
    end

    it 'knows that an all day event has started on or after the date of the event' do
      expect(all_day).to be_started(Time.zone.local(2015, 1, 15, 12, 0, 0), 'America/New_York')
    end

    it 'knows that an all day event has not started before the date of the event' do
      expect(all_day).not_to be_started(Time.zone.local(2015, 1, 14, 14, 0, 0), 'America/New_York')
    end

    it 'knows that a relative time event has started after the time of the event' do
      expect(relative).to be_started(Time.zone.local(2015, 1, 20, 13, 0, 0), 'America/New_York')
    end

    it 'knows that a relative time event has not started before the time fo the event' do
      expect(relative).not_to be_started(Time.zone.local(2015, 1, 10, 13, 0, 0), 'America/New_York')
    end

    it 'knows that a recurring time event has started after the time of the event' do
      expect(recurring).to be_started(Time.zone.local(2015, 1, 15, 16, 0, 0), 'America/New_York')
    end

    it 'knows that a recurring time event has not started before the time of the event' do
      expect(recurring).not_to be_started(Time.zone.local(2015, 1, 15, 13, 0, 0), 'America/New_York')
    end

    it 'knows that a tv show event has started after the time of the event' do
      expect(tv_show).to be_started(Time.zone.local(2015, 1, 15, 18, 30, 0), 'America/New_York')
    end

    it 'knows that a tv show event has not started before the time of the event' do
      expect(tv_show).not_to be_started(Time.zone.local(2015, 1, 15, 17, 30, 0), 'America/New_York')
    end
  end

  describe 'datetime getters' do
    let(:all_day_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, is_all_day: true }
    let(:relative_time_event) { create :event, datetime: Time.utc(2014, 1, 24, 3, 0, 0) }
    let(:tv_show_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, local_time: '6:00 PM', time_format: 'tv_show' }
    let(:recurring_time_event) { create :event, local_date: Time.local(2014, 1, 24).to_date, local_time: '6:00 PM', time_format: 'recurring' }

    describe 'event#datetime_string' do
      let(:another_event) { create :event, local_date: Time.local(2014, 3, 11).to_date, is_all_day: true }

      it 'maps the ordinal correctly for 24th' do
        expect(all_day_event.datetime_string('America/New_York')).to eq 'Friday, Jan 24th 2014, All Day'
      end

      it 'maps the 11th' do
        expect(another_event.datetime_string('America/New_York')).to eq 'Tuesday, Mar 11th 2014, All Day'
      end
    end

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

    describe 'friendly print' do
      it 'looks nice for all day events' do
        expect(all_day_event.pretty_time('America/New_York')).to eq 'All Day'
      end

      it 'looks nice for tv show events' do
        expect(tv_show_event.pretty_time('America/New_York')).to eq '6:00/5:00c'
      end

      it 'looks nice for relative time events' do
        expect(relative_time_event.pretty_time('America/New_York')).to eq '10:00pm'
      end

      it 'looks nice for recurring time events' do
        expect(recurring_time_event.pretty_time('America/New_York')).to eq '6:00pm'
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

  describe 'updating reminders' do
    let(:event) { create :event }
    let(:user) { create :user }
    let(:user) { create :user }

    it 'should determine if a time has changed' do
      event.update_attributes({ is_all_day: true })
      expect(event.time_changed?).to eq true
      event.update_attributes({name: 'foobar' })
      expect(event.time_changed?).to eq false
    end

    it 'should set all reminders to pending' do
      create :reminder, :one_h_before, event: event, user: user
      event.reminders.each { |r| r.update_attributes(status: Reminder::STATUS_DELIVERED) }
      expect(event.reminders.first.status).to eq Reminder::STATUS_DELIVERED
      event.set_all_reminders_pending
      expect(event.reminders.first.status).to eq Reminder::STATUS_PENDING
    end
  end
end
