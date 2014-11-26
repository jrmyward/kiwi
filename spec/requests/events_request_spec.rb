require 'spec_helper'

describe 'Events Requests' do
  before(:each) do
    # setup token and authentication
  end

  # Paginated collection
  describe 'GET /api/1/events' do
    let!(:subkasts) do
      create :subkast, code: 'TV'
      create :subkast, code: 'ST'
    end

    let!(:e1) { create :event, name: 'E1', local_date: DateTime.parse("Sep 15th, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4' ] }
    let!(:e2) { create :event, name: 'E2', local_date: DateTime.parse("Sep 15th, 2014").to_date, local_time: "7:30 PM", time_format: 'tv_show', upvote_names: ['v1', 'v2'], subkast: 'TV', description: 'This should be interesting.' }
    let!(:e3) { create :event, name: 'E3', local_date: DateTime.parse("Sep 15th, 2014").to_date, local_time: "2:30 PM", time_format: 'recurring', upvote_names: ['v1', 'v2', 'v3'], location_type: 'international' }
    let!(:e4) { create :event, name: 'E4', datetime: DateTime.parse("Sep 15th, 2014 12:00 PM") }

    let!(:e5) { create :event, name: 'E5', local_date: DateTime.parse("Sep 16th, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4' ] }

    it 'should be able to fetch events on a given date' do
      get '/api/1/events', { on_date: '2014-09-15', time_zone: 'America/New_York', country: 'CA' }

      expect(response.status).to eq 200

      resp = JSON.parse(response.body)['response']

      expect(resp[0]['name']).to eq 'E1'
      expect(resp[0]['subkast']).to eq 'ST'
      expect(resp[0]['location_type']).to eq 'national'
      expect(resp[0]['country']).to eq 'CA'
      expect(resp[0]['date']).to eq '2014-09-15'
      expect(resp[0]['all_day']).to eq true
      expect(resp[0]['added_by']).to eq 'mr. x'
      expect(resp[0]['description']).to eq 'This should be exciting!'
      expect(resp[0]['upvotes_url']).to eq "/api/1/events/#{e1.id}/upvote"
      expect(resp[0]['comments_url']).to eq "/api/1/events/#{e1.id}/comments"
      expect(resp[0]['reminders_url']).to eq "/api/1/events/#{e1.id}/reminders"

      expect(resp[1]['name']).to eq 'E3'
      expect(resp[1]['subkast']).to eq 'ST'
      expect(resp[1]['location_type']).to eq 'international'
      expect(resp[1]['datetime']).to eq '2014-09-15T14:30:00'
      expect(resp[1]['recurring']).to eq true
      expect(resp[1]['added_by']).to eq 'mr. x'
      expect(resp[1]['description']).to eq 'This should be exciting!'
      expect(resp[1]['upvotes_url']).to eq "/api/1/events/#{e3.id}/upvote"
      expect(resp[1]['comments_url']).to eq "/api/1/events/#{e3.id}/comments"
      expect(resp[1]['reminders_url']).to eq "/api/1/events/#{e3.id}/reminders"

      expect(resp[2]['name']).to eq 'E2'
      expect(resp[2]['subkast']).to eq 'TV'
      expect(resp[2]['location_type']).to eq 'national'
      expect(resp[2]['country']).to eq 'CA'
      expect(resp[2]['datetime']).to eq '2014-09-15T23:30:00'
      expect(resp[2]['tv_show']).to eq true
      expect(resp[2]['added_by']).to eq 'mr. x'
      expect(resp[2]['description']).to eq 'This should be interesting.'
      expect(resp[2]['upvotes_url']).to eq "/api/1/events/#{e2.id}/upvote"
      expect(resp[2]['comments_url']).to eq "/api/1/events/#{e2.id}/comments"
      expect(resp[2]['reminders_url']).to eq "/api/1/events/#{e2.id}/reminders"

      expect(resp[3]['name']).to eq 'E4'
      expect(resp[3]['subkast']).to eq 'ST'
      expect(resp[3]['location_type']).to eq 'national'
      expect(resp[3]['country']).to eq 'CA'
      expect(resp[3]['datetime']).to eq '2014-09-15T12:00:00'
      expect(resp[3]['relative']).to eq true
      expect(resp[3]['added_by']).to eq 'mr. x'
      expect(resp[3]['description']).to eq 'This should be exciting!'
      expect(resp[3]['upvotes_url']).to eq "/api/1/events/#{e4.id}/upvote"
      expect(resp[3]['comments_url']).to eq "/api/1/events/#{e4.id}/comments"
      expect(resp[3]['reminders_url']).to eq "/api/1/events/#{e4.id}/reminders"
    end

    xit 'should be able to fetch events following a given date' do
      get '/api/1/events', { after_date: '2014-10-22', time_zone: 'America/New_York' }

    end

    xit 'should be able to fetch events following and including a given date' do
      get '/api/1/events', { after_date: '2014-10-22', time_zone: 'America/New_York', include_date: true }

    end
  end

  describe 'POST /events' do
    xit 'should be able to create an all day event' do
      event = {
        name: 'Canada Day',
        subkast: 'HA',
        international: false,
        country: 'CA',
        date: '2014-07-01',
        all_day: true,
        description: 'Celebration of Canada\'s birthday!'
      }
      post '/api/1/events', event 
    end

    xit 'should be able to create a relative time event' do
     event = {
        name: 'Hangout with Harper',
        subkast: 'EDU',
        international: false,
        country: 'CA',
        date: '2014-07-01',
        time: '19:00',
        time_zone: 'America/New_York',
        description: 'Celebration of Canada\'s birthday!'
      }
      post '/api/1/events', event 
    end

    # Time zone doesn't matter
    xit 'should be able to create a recurring time event' do
      event = {
        name: 'School Starts',
        subkast: 'EDU',
        international: false,
        country: 'CA',
        date: '2014-08-01',
        time: '8:30',
        description: 'First day of classes'
      }
      post '/api/1/events', event 
    end

    # Time is assumed to be in eastern time
    xit 'should be able to create tv show event' do
      event = {
        name: 'Hocket Night in Canada',
        subkast: 'SP',
        international: false,
        country: 'CA',
        date: '2014-07-01',
        time: '19:00',
        description: 'With George Strombolo...'
      }
      post '/api/1/events', event 
    end

    it 'should be able to create international events' do
      event = {
        name: 'Canada Day',
        subkast: 'HA',
        international: true,
        date: '2014-07-01',
        all_day: true,
        description: 'Celebration of Canada\'s birthday!'
      }
      post '/api/1/events', event 
    end

    it 'should be able to create events with an image' do
      event = {
        name: 'Canada Day',
        subkast: 'HA',
        international: true,
        date: '2014-07-01',
        all_day: true,
        description: 'Celebration of Canada\'s birthday!',
        image_url: 'http://somewhere.com/image.png',
        crop_x: 20,
        crop_y: 50,
        width: 100,
        height: 150
      }
      post '/api/1/events', event 
    end
  end

  describe 'PUT /events' do
    xit 'should be able to update an event' do

    end
  end

  describe 'DELETE /events/{id}' do
    xit 'should be able to delete an event' do

    end
  end
end
