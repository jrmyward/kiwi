require 'spec_helper'

describe 'Events Requests' do
  before(:each) do
    # setup token and authentication
  end

  # Paginated collection
  describe 'GET /api/1/events' do
    it 'should be able to fetch events on a given date' do
      get '/api/1/events', { on_date: '2014-10-22', time_zone: 'America/New_York' }

      expect(response.status).to eq 200
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
