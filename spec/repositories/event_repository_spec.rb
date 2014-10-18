require 'spec_helper'

describe EventRepository do
  let(:repository) { EventRepository.new("America/New_York", "CA", ["ST"]) }

  def all_day_event(date)
    create :event, local_date: DateTime.parse(date).to_date, is_all_day: true
  end

  def tv_show_event(date, time)
    create :event, local_date: DateTime.parse(date).to_date, local_time: time, time_format: 'tv_show'
  end

  def recurring_event(date, time)
    create :event, local_date: DateTime.parse(date).to_date, local_time: time, time_format: 'recurring'
  end

  def relative_event(date, time, time_zone)
    create :event, datetime: DateTime.parse("#{date} #{time}")
  end

  def assign_upvotes(event, upvotes)
    event.upvote_names = upvotes
    event.save
  end

  before(:each) do
    @three_upvotes = ['voter1', 'voter2', 'voter3']
    @four_upvotes = ['voter1', 'voter2', 'voter3', 'voter4']
    @five_upvotes = ['voter1', 'voter2', 'voter3', 'voter4', 'voter5']
    @ten_upvotes = ['voter1', 'voter2', 'voter3', 'voter4', 'voter5', 'voter6', 'voter7', 'voter8', 'voter9', 'voter10']

    @e1 = all_day_event("Sep 15th, 2014")
    @e2 = all_day_event("Sep 16th, 2014")

    @e3 = tv_show_event("Sep 15th, 2014", "7:30 PM")
    @e4 = tv_show_event("Sep 16th, 2014", "7:30 PM")

    @e5 = recurring_event("Sep 15th, 2014", "1:30 PM")
    @e6 = recurring_event("Sep 16th, 2014", "1:30 PM")

    @e7 = relative_event("Sep 15th, 2014", "10:30 AM", "America/New_York")
    @e8 = relative_event("Sep 16th, 2014", "10:30 AM", "America/New_York")

    assign_upvotes(@e4, @ten_upvotes)
    assign_upvotes(@e5, @ten_upvotes)

    assign_upvotes(@e2, @five_upvotes)
    assign_upvotes(@e7, @five_upvotes)

    assign_upvotes(@e8, @four_upvotes)
    assign_upvotes(@e3, @four_upvotes)

    assign_upvotes(@e1, @three_upvotes)
    assign_upvotes(@e6, @three_upvotes)
  end

  describe 'fetching events on a given date' do

    it 'should be able to fetch all events on a given date' do
      expect(repository.events_on_date("Sep 15th, 2014")).to eq [@e5, @e7, @e3, @e1]
    end


    it 'should be able to fetch a given number of events on a given date' do
      expect(repository.events_on_date("Sep 15th, 2014", 3)).to eq [@e5, @e7, @e3]
    end

    it 'should be able to skip a given number of events' do
      expect(repository.events_on_date("Sep 15th, 2014", 0, 1)).to eq [@e7, @e3, @e1]
    end

  end

  it 'should be able to fetch a given number of events on a given date and skip some events' do

  end

  it 'should be able to count the number of events on a given day' do

  end

  it 'should be able to fetch a few events for a given number of upcoming days' do

  end
end
