require 'spec_helper'

describe EventRepository do
  let(:repository) { EventRepository.new("America/New_York", "CA", ["ST"]) }

  context 'not create time sensitive' do

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

    let!(:e13) { create :event, name: 'E13', local_date: DateTime.parse("Sep 22nd, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7' ] }
    let!(:e14) { create :event, name: 'E14', local_date: DateTime.parse("Sep 18th, 2014").to_date, local_time: "7:30 PM", time_format: 'tv_show', upvote_names: ['v1', 'v2', 'v3', 'v4', 'v5', 'v6'] }
    let!(:e15) { create :event, name: 'E15', local_date: DateTime.parse("Sep 19th, 2014").to_date, local_time: "2:30 PM", time_format: 'recurring', upvote_names: ['v1', 'v2', 'v3', 'v4', 'v5'] }
    let!(:e16) { create :event, name: 'E16', datetime: DateTime.parse("Sep 16th, 2014 12:00 PM"), upvote_names: ['v1', 'v2', 'v3', 'v4', 'v5'] }

    describe 'fetching events on a given date' do

      it 'should be able to fetch all events on a given date' do
        expect(repository.events_on_date("Sep 15th, 2014")).to eq [e1, e9, e3, e11, e2]
      end

      it 'should be able to fetch a given number of events on a given date' do
        expect(repository.events_on_date("Sep 15th, 2014", 0, 6)).to eq [e1, e9, e3, e11, e2, e10]
      end

      it 'should be able to skip a given number of events' do
        expect(repository.events_on_date("Sep 15th, 2014", 2, 5)).to eq [e3, e11, e2, e10, e4]
      end

      it 'should be able to fetch all events on a given date' do
        expect(repository.events_on_date("Sep 15th, 2014", 0, 10)).to eq [e1, e9, e3, e11, e2, e10, e4, e12]
      end

      it 'should return an empty array when skipping over all the events' do
        expect(repository.events_on_date("Sep 15th, 2014", 20)).to eq []
      end
    end

    it 'should be able to count the number of events on a given day' do
      expect(repository.count_events_on_date("Sep 15th, 2014")).to eq 8
    end

    it 'should be able to fetch a given number of top ranked events over a given range of days' do
      expect(repository.top_ranked_events("Sep 15th, 2014", "Sep 22nd, 2014", 10)).to eq [e13, e14, e15, e16, e1, e5, e9, e3, e7, e11]
    end

    describe 'fetching events from date' do

      it 'should be able to fetch a few events for a given number of upcoming days' do
        expect(repository.events_from_date("Sep 15th, 2014", 3)).to eq [e1, e9, e3, e16, e5, e7, e14]
      end

      it 'should be able to fetch a fixed number of events per day' do
        expect(repository.events_from_date("Sep 15th, 2014", 3, 5)).to eq [e1, e9, e3, e11, e2, e16, e5, e7, e6, e8, e14]
      end

      it 'should be able to stop when it reaches the last date' do
        expect(repository.events_from_date("Sep 23rd, 2014", 3)).to eq []
      end
    end
  end

  context 'create time sensitive' do
    let!(:e1) do
      Timecop.freeze(DateTime.new(2015, 1, 5, 12, 0, 0))
      e = create :event, name: 'E1'
      Timecop.return
      e
    end

    let!(:e2) do
      Timecop.freeze(DateTime.new(2015, 1, 11, 12, 0, 0))
      e = create :event, name: 'E2'
      Timecop.return
      e
    end

    let!(:e3) do
      Timecop.freeze(DateTime.new(2015, 1, 13, 12, 0, 0))
      e = create :event, name: 'E3'
      Timecop.return
      e
    end

    let!(:e4) do
      Timecop.freeze(DateTime.new(2015, 1, 8, 12, 0, 0))
      e = create :event, name: 'E4'
      Timecop.return
      e
    end

    describe 'most recent events' do
      it 'gets events in the order they were created' do
        expect(repository.most_recent_events(30)).to eq [e3, e2, e4, e1]
      end

      it 'limits the number of recent evets retrieved' do
        expect(repository.most_recent_events(3)).to eq [e3, e2, e4]
      end
    end
  end
end
