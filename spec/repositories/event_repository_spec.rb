require 'spec_helper'

describe EventRepository do
  let(:repository) { EventRepository.new("America/New_York", "CA", ["ST"]) }

  let!(:e1) { create :event, name: 'E1', local_date: DateTime.parse("Sep 15th, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4' ] }
  let!(:e2) { create :event, name: 'E2', local_date: DateTime.parse("Sep 15th, 2014").to_date, local_time: "7:30 PM", time_format: 'tv_show', upvote_names: ['v1', 'v2'] }
  let!(:e3) { create :event, name: 'E3', local_date: DateTime.parse("Sep 15th, 2014").to_date, local_time: "2:30 PM", time_format: 'recurring', upvote_names: ['v1', 'v2', 'v3'] }
  let!(:e4) { create :event, name: 'E4', datetime: DateTime.parse("Sep 15th, 2014 12:00 PM") }

  let!(:e5) { create :event, name: 'E5', local_date: DateTime.parse("Sep 16th, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4' ] }
  let!(:e6) { create :event, name: 'E6', local_date: DateTime.parse("Sep 16th, 2014").to_date, local_time: "7:30 PM", time_format: 'tv_show', upvote_names: ['v1', 'v2'] }
  let!(:e7) { create :event, name: 'E7', local_date: DateTime.parse("Sep 16th, 2014").to_date, local_time: "2:30 PM", time_format: 'recurring', upvote_names: ['v1', 'v2', 'v3'] }
  let!(:e8) { create :event, name: 'E8', datetime: DateTime.parse("Sep 16th, 2014 12:00 PM") }

  let!(:e9) { create :event, name: 'E9', local_date: DateTime.parse("Sep 15th, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4' ], location_type: 'international', country: '' }
  let!(:e10) { create :event, name: 'E10', local_date: DateTime.parse("Sep 15th, 2014").to_date, local_time: "7:30 PM", time_format: 'tv_show', upvote_names: ['v1', 'v2'], location_type: 'international', country: '' }
  let!(:e11) { create :event, name: 'E11', local_date: DateTime.parse("Sep 15th, 2014").to_date, local_time: "2:30 PM", time_format: 'recurring', upvote_names: ['v1', 'v2', 'v3'], location_type: 'international', country: '' }
  let!(:e12) { create :event, name: 'E12', datetime: DateTime.parse("Sep 15th, 2014 12:00 PM"), location_type: 'international', country: '' }

  describe 'fetching events on a given date' do

    it 'should be able to fetch all events on a given date' do
      expect(repository.events_on_date("Sep 15th, 2014")).to eq [e1, e9, e3, e11, e2, e10, e4, e12]
    end

    it 'should be able to fetch a given number of events on a given date' do
      expect(repository.events_on_date("Sep 15th, 2014", 6)).to eq [e1, e9, e3, e11, e2, e10]
    end

    it 'should be able to skip a given number of events' do
      expect(repository.events_on_date("Sep 15th, 2014", 5, 2)).to eq [e3, e11, e2, e10, e4]
    end
  end

  it 'should be able to fetch a given number of events on a given date and skip some events' do

  end

  it 'should be able to count the number of events on a given day' do

  end

  it 'should be able to fetch a few events for a given number of upcoming days' do

  end
end
