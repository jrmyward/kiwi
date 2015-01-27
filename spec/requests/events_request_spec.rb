require 'spec_helper'

describe 'Events Requests' do
  #TODO: Paginated collection
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

    let!(:e10) { create :event, name: 'E10', local_date: DateTime.parse("Sep 23rd, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3' ] }

    let!(:e6) { create :event, name: 'E6', local_date: DateTime.parse("Sep 23rd, 2014").to_date, is_all_day: true, upvote_names: ['v1', 'v2', 'v3', 'v4' ] }
    let!(:e7) { create :event, name: 'E7', local_date: DateTime.parse("Sep 24th, 2014").to_date, local_time: "7:30 PM", time_format: 'tv_show', upvote_names: ['v1', 'v2'], subkast: 'TV', description: 'This should be interesting.' }
    let!(:e8) { create :event, name: 'E8', local_date: DateTime.parse("Sep 25th, 2014").to_date, local_time: "2:30 PM", time_format: 'recurring', upvote_names: ['v1', 'v2', 'v3'], subkast: 'TV', location_type: 'international' }
    let!(:e9) { create :event, name: 'E9', datetime: DateTime.parse("Sep 26th, 2014 12:00 PM"), local_date: DateTime.parse("Sep 26th, 2014").to_date }


    it 'should be able to fetch events on a given date' do
      get '/api/1/events', { on_date: '2014-09-15', time_zone: 'America/New_York', country: 'CA' }

      expect(response.status).to eq 200

      resp = JSON.parse(response.body)['response']

      expect(resp[0]['name']).to eq 'E1'
      expect(resp[0]['subkast']).to eq 'ST'
      expect(resp[0]['country']).to eq 'CA'
      expect(resp[0]['date']).to eq '2014-09-15'
      expect(resp[0]['all_day']).to eq true
      expect(resp[0]['added_by']).to eq 'mrx'
      expect(resp[0]['description']).to eq 'This should be exciting!'
      expect(resp[0]['upvote_count']).to eq 4
      expect(resp[0]['upvotes_url']).to eq "/api/1/events/#{e1.id}/upvote"
      expect(resp[0]['comments_url']).to eq "/api/1/events/#{e1.id}/comments"
      expect(resp[0]['reminders_url']).to eq "/api/1/events/#{e1.id}/reminders"

      expect(resp[1]['name']).to eq 'E3'
      expect(resp[1]['subkast']).to eq 'ST'
      expect(resp[1]['international']).to be
      expect(resp[1]['datetime']).to eq '2014-09-15T14:30:00'
      expect(resp[1]['recurring']).to eq true
      expect(resp[1]['added_by']).to eq 'mrx'
      expect(resp[1]['description']).to eq 'This should be exciting!'
      expect(resp[1]['upvote_count']).to eq 3
      expect(resp[1]['upvotes_url']).to eq "/api/1/events/#{e3.id}/upvote"
      expect(resp[1]['comments_url']).to eq "/api/1/events/#{e3.id}/comments"
      expect(resp[1]['reminders_url']).to eq "/api/1/events/#{e3.id}/reminders"

      expect(resp[2]['name']).to eq 'E2'
      expect(resp[2]['subkast']).to eq 'TV'
      expect(resp[2]['country']).to eq 'CA'
      expect(resp[2]['datetime']).to eq '2014-09-15T19:30:00'
      expect(resp[2]['eastern_tv_show']).to eq true
      expect(resp[2]['eastern_tv_time']).to eq '7:30/6:30c'
      expect(resp[2]['added_by']).to eq 'mrx'
      expect(resp[2]['description']).to eq 'This should be interesting.'
      expect(resp[2]['upvote_count']).to eq 2
      expect(resp[2]['upvotes_url']).to eq "/api/1/events/#{e2.id}/upvote"
      expect(resp[2]['comments_url']).to eq "/api/1/events/#{e2.id}/comments"
      expect(resp[2]['reminders_url']).to eq "/api/1/events/#{e2.id}/reminders"

      expect(resp[3]['name']).to eq 'E4'
      expect(resp[3]['subkast']).to eq 'ST'
      expect(resp[3]['country']).to eq 'CA'
      expect(resp[3]['datetime']).to eq '2014-09-15T08:00:00'
      expect(resp[3]['relative']).to eq true
      expect(resp[3]['added_by']).to eq 'mrx'
      expect(resp[3]['description']).to eq 'This should be exciting!'
      expect(resp[3]['upvote_count']).to eq 0
      expect(resp[3]['upvotes_url']).to eq "/api/1/events/#{e4.id}/upvote"
      expect(resp[3]['comments_url']).to eq "/api/1/events/#{e4.id}/comments"
      expect(resp[3]['reminders_url']).to eq "/api/1/events/#{e4.id}/reminders"
    end

    it 'should be able to fetch events following a given date' do
      get '/api/1/events', { after_date: '2014-09-22', time_zone: 'America/New_York', country: 'CA' }

      expect(response.status).to eq 200

      resp = JSON.parse(response.body)['response']

      expect(resp[0]['name']).to eq 'E6'
      expect(resp[0]['subkast']).to eq 'ST'
      expect(resp[0]['country']).to eq 'CA'
      expect(resp[0]['date']).to eq '2014-09-23'
      expect(resp[0]['all_day']).to eq true
      expect(resp[0]['added_by']).to eq 'mrx'
      expect(resp[0]['description']).to eq 'This should be exciting!'
      expect(resp[0]['upvote_count']).to eq 4
      expect(resp[0]['upvotes_url']).to eq "/api/1/events/#{e6.id}/upvote"
      expect(resp[0]['comments_url']).to eq "/api/1/events/#{e6.id}/comments"
      expect(resp[0]['reminders_url']).to eq "/api/1/events/#{e6.id}/reminders"

      expect(resp[1]['name']).to eq 'E10'
      expect(resp[1]['subkast']).to eq 'ST'
      expect(resp[1]['country']).to eq 'CA'
      expect(resp[1]['date']).to eq '2014-09-23'
      expect(resp[1]['all_day']).to eq true
      expect(resp[1]['added_by']).to eq 'mrx'
      expect(resp[1]['description']).to eq 'This should be exciting!'
      expect(resp[1]['upvote_count']).to eq 3
      expect(resp[1]['upvotes_url']).to eq "/api/1/events/#{e10.id}/upvote"
      expect(resp[1]['comments_url']).to eq "/api/1/events/#{e10.id}/comments"
      expect(resp[1]['reminders_url']).to eq "/api/1/events/#{e10.id}/reminders"

      expect(resp[2]['name']).to eq 'E7'
      expect(resp[2]['subkast']).to eq 'TV'
      expect(resp[2]['country']).to eq 'CA'
      expect(resp[2]['datetime']).to eq '2014-09-24T19:30:00'
      expect(resp[2]['eastern_tv_show']).to eq true
      expect(resp[2]['eastern_tv_time']).to eq '7:30/6:30c'
      expect(resp[2]['added_by']).to eq 'mrx'
      expect(resp[2]['description']).to eq 'This should be interesting.'
      expect(resp[2]['upvote_count']).to eq 2
      expect(resp[2]['upvotes_url']).to eq "/api/1/events/#{e7.id}/upvote"
      expect(resp[2]['comments_url']).to eq "/api/1/events/#{e7.id}/comments"
      expect(resp[2]['reminders_url']).to eq "/api/1/events/#{e7.id}/reminders"

      expect(resp[3]['name']).to eq 'E8'
      expect(resp[3]['subkast']).to eq 'TV'
      expect(resp[3]['international']).to be
      expect(resp[3]['datetime']).to eq '2014-09-25T14:30:00'
      expect(resp[3]['recurring']).to eq true
      expect(resp[3]['added_by']).to eq 'mrx'
      expect(resp[3]['description']).to eq 'This should be exciting!'
      expect(resp[3]['upvote_count']).to eq 3
      expect(resp[3]['upvotes_url']).to eq "/api/1/events/#{e8.id}/upvote"
      expect(resp[3]['comments_url']).to eq "/api/1/events/#{e8.id}/comments"
      expect(resp[3]['reminders_url']).to eq "/api/1/events/#{e8.id}/reminders"

      expect(resp[4]['name']).to eq 'E9'
      expect(resp[4]['subkast']).to eq 'ST'
      expect(resp[4]['country']).to eq 'CA'
      expect(resp[4]['datetime']).to eq '2014-09-26T08:00:00'
      expect(resp[4]['relative']).to eq true
      expect(resp[4]['added_by']).to eq 'mrx'
      expect(resp[4]['description']).to eq 'This should be exciting!'
      expect(resp[4]['upvote_count']).to eq 0
      expect(resp[4]['upvotes_url']).to eq "/api/1/events/#{e9.id}/upvote"
      expect(resp[4]['comments_url']).to eq "/api/1/events/#{e9.id}/comments"
      expect(resp[4]['reminders_url']).to eq "/api/1/events/#{e9.id}/reminders"
    end

    it 'filters by subkast and returns only matching events' do
      get '/api/1/events', { after_date: '2014-09-22', time_zone: 'America/New_York', country: 'CA', subkast: 'TV' }

      expect(response.status).to eq 200

      resp = JSON.parse(response.body)['response']

      expect(resp[0]['name']).to eq 'E7'
      expect(resp[0]['subkast']).to eq 'TV'
      expect(resp[0]['country']).to eq 'CA'
      expect(resp[0]['datetime']).to eq '2014-09-24T19:30:00'
      expect(resp[0]['eastern_tv_show']).to eq true
      expect(resp[0]['eastern_tv_time']).to eq '7:30/6:30c'
      expect(resp[0]['added_by']).to eq 'mrx'
      expect(resp[0]['description']).to eq 'This should be interesting.'
      expect(resp[0]['upvote_count']).to eq 2
      expect(resp[0]['upvotes_url']).to eq "/api/1/events/#{e7.id}/upvote"
      expect(resp[0]['comments_url']).to eq "/api/1/events/#{e7.id}/comments"
      expect(resp[0]['reminders_url']).to eq "/api/1/events/#{e7.id}/reminders"

      expect(resp[1]['name']).to eq 'E8'
      expect(resp[1]['subkast']).to eq 'TV'
      expect(resp[1]['international']).to be
      expect(resp[1]['datetime']).to eq '2014-09-25T14:30:00'
      expect(resp[1]['recurring']).to eq true
      expect(resp[1]['added_by']).to eq 'mrx'
      expect(resp[1]['description']).to eq 'This should be exciting!'
      expect(resp[1]['upvote_count']).to eq 3
      expect(resp[1]['upvotes_url']).to eq "/api/1/events/#{e8.id}/upvote"
      expect(resp[1]['comments_url']).to eq "/api/1/events/#{e8.id}/comments"
      expect(resp[1]['reminders_url']).to eq "/api/1/events/#{e8.id}/reminders"

    end
  end

  describe 'GET /events/{id}' do
    let!(:event) { create :event, name: 'Event X', datetime: DateTime.parse("Sep 15th, 2014 12:00 PM") }

    it 'reponds wtih the requested event and a 200 status code' do
      get "/api/1/events/#{event.id}"

      expect(response.code).to eq '200'

      resp = JSON.parse(response.body)['response']

      expect(resp['name']).to eq 'Event X'
      expect(resp['subkast']).to eq 'ST'
      expect(resp['country']).to eq 'CA'
      expect(resp['datetime']).to eq '2014-09-15T08:00:00'
      expect(resp['relative']).to eq true
      expect(resp['added_by']).to eq 'mrx'
      expect(resp['description']).to eq 'This should be exciting!'
      expect(resp['upvote_count']).to eq 0
      expect(resp['upvotes_url']).to eq "/api/1/events/#{event.id}/upvote"
      expect(resp['comments_url']).to eq "/api/1/events/#{event.id}/comments"
      expect(resp['reminders_url']).to eq "/api/1/events/#{event.id}/reminders"
    end
  end

  describe 'POST /events' do

    context 'signed in' do
      let(:u1) { create :user }

      before(:each) do
        sign_in(u1)
      end

      it 'should be able to create an all day event' do
        event = {
          name: 'Canada Day',
          subkast: 'HA',
          country: 'CA',
          date: '2014-07-01',
          all_day: true,
          description: 'Celebration of Canada\'s birthday!'
        }

        post '/api/1/events', event

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['id']).to be
        expect(resp['name']).to eq 'Canada Day'
        expect(resp['subkast']).to eq 'HA'
        expect(resp['all_day']).to be
        expect(resp['country']).to eq 'CA'
        expect(resp['date']).to eq '2014-07-01'
        expect(resp['description']).to eq 'Celebration of Canada\'s birthday!'
        expect(resp['upvote_count']).to eq 1
        expect(resp['upvoted']).to be
        expect(resp['added_by']).to eq u1.username
      end

      it 'should be able to create a relative time event' do
       event = {
          name: 'Hangout with Harper',
          subkast: 'EDU',
          country: 'CA',
          date: '2014-07-01',
          time: '19:00',
          time_zone: 'America/New_York',
          description: 'Celebration of Canada\'s birthday!'
        }
        post '/api/1/events', event

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['id']).to be
        expect(resp['name']).to eq 'Hangout with Harper'
        expect(resp['subkast']).to eq 'EDU'
        expect(resp['country']).to eq 'CA'
        expect(resp['datetime']).to eq '2014-07-01T19:00:00'
        expect(resp['description']).to eq 'Celebration of Canada\'s birthday!'
        expect(resp['upvote_count']).to eq 1
        expect(resp['upvoted']).to be
        expect(resp['added_by']).to eq u1.username
      end

      it 'should be able to create a recurring time event' do
        event = {
          name: 'School Starts',
          subkast: 'EDU',
          country: 'CA',
          date: '2014-08-01',
          time: '8:30',
          recurring: true,
          description: 'First day of classes'
        }
        post '/api/1/events', event

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['id']).to be
        expect(resp['name']).to eq 'School Starts'
        expect(resp['subkast']).to eq 'EDU'
        expect(resp['country']).to eq 'CA'
        expect(resp['datetime']).to eq '2014-08-01T08:30:00'
        expect(resp['recurring']).to be
        expect(resp['description']).to eq 'First day of classes'
        expect(resp['upvote_count']).to eq 1
        expect(resp['upvoted']).to be
        expect(resp['added_by']).to eq u1.username
      end

      it 'should be able to create tv show event' do
        event = {
          name: 'Hockey Night in Canada',
          subkast: 'SP',
          country: 'CA',
          date: '2014-07-01',
          time: '19:00',
          eastern_tv_show: true,
          description: 'With George Strombolo...'
        }
        post '/api/1/events', event

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['id']).to be
        expect(resp['name']).to eq 'Hockey Night in Canada'
        expect(resp['subkast']).to eq 'SP'
        expect(resp['country']).to eq 'CA'
        expect(resp['datetime']).to eq '2014-07-01T19:00:00'
        expect(resp['eastern_tv_show']).to be
        expect(resp['eastern_tv_time']).to eq '7:00/6:00c'
        expect(resp['description']).to eq 'With George Strombolo...'
        expect(resp['upvote_count']).to eq 1
        expect(resp['upvoted']).to be
        expect(resp['added_by']).to eq u1.username
      end

      it 'should be able to create international events' do
        event = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }
        post '/api/1/events', event

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['id']).to be
        expect(resp['name']).to eq 'World Day'
        expect(resp['subkast']).to eq 'HA'
        expect(resp['international']).to be
        expect(resp['all_day']).to be
        expect(resp['date']).to eq '2014-09-01'
        expect(resp['description']).to eq 'Celebration of world day!'
        expect(resp['upvote_count']).to eq 1
        expect(resp['upvoted']).to be
        expect(resp['added_by']).to eq u1.username
      end
    end

    context 'not signed in' do
      it 'replies with a 401 status code and unauthorized error message' do
        event = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }
        post '/api/1/events', event

        expect(response.code).to eq '401'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'unauthenticated'
        expect(resp['error_description']).to eq 'This action requires authentication to continue.'
      end
    end
  end

  describe 'PUT /api/1/events/{id}' do
    let(:mrx) { create :user, username: 'mrx' }
    let(:mod) { create :moderator }
    let(:otherguy) { create :user }

    let!(:e) { create :event }

    context 'signed in' do
      it 'as the event owner, can update the event' do
        sign_in mrx

        event_update = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }

        put "/api/1/events/#{e.id}", event_update

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['name']).to eq 'World Day'
        expect(resp['subkast']).to eq 'HA'
        expect(resp['international']).to be
        expect(resp['all_day']).to be
        expect(resp['date']).to eq '2014-09-01'
        expect(resp['description']).to eq 'Celebration of world day!'
      end

      it 'gets a 404 status code and an error message when the event could not be found' do
        sign_in mrx

        event_update = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }

        put '/api/1/events/ZZZ', event_update

        expect(response.code).to eq '404'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'not_found'
        expect(resp['error_description']).to eq 'The requested resource could not be found.'
      end

      it 'as a moderator, can update the event' do
        sign_in mod

        event_update = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }

        put "/api/1/events/#{e.id}", event_update

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp['name']).to eq 'World Day'
        expect(resp['subkast']).to eq 'HA'
        expect(resp['international']).to be
        expect(resp['all_day']).to be
        expect(resp['date']).to eq '2014-09-01'
        expect(resp['description']).to eq 'Celebration of world day!'
      end

      it 'as the other guy, reply with a 401 status code and unauthorized error message' do
        sign_in otherguy

        event_update = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }

        put "/api/1/events/#{e.id}", event_update

        expect(response.code).to eq '403'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'forbidden'
        expect(resp['error_description']).to eq 'The action you requested was forbidden.'
      end
    end

    context 'not signed in' do
      it 'returns with a 401 error code and an unauthorized message' do
        event_update = {
          name: 'World Day',
          subkast: 'HA',
          international: true,
          date: '2014-09-01',
          all_day: true,
          description: 'Celebration of world day!'
        }

        put "/api/1/events/#{e.id}", event_update

        expect(response.code).to eq '401'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'unauthenticated'
        expect(resp['error_description']).to eq 'This action requires authentication to continue.'
      end
    end
  end

  describe 'DELETE /events/{id}' do
    let!(:e) { create :event }

    let(:mrx) { create :user, username: 'mrx' }
    let(:mod) { create :moderator }
    let(:otherguy) { create :user }

    it 'signed in as the event owner deleted the event' do
      sign_in mrx
      delete "/api/1/events/#{e.id}"

      expect(response.code).to eq '200'

      expect(Event.where(id: e.id).first).to be_nil
    end

    it 'replies with a 404 status code and error message when the event could not be found' do
      sign_in mrx

      delete '/api/1/events/ZZZ'

      expect(response.code).to eq '404'

      resp = JSON.parse(response.body)

      expect(resp['error']).to eq 'not_found'
      expect(resp['error_description']).to eq 'The requested resource could not be found.'
    end

    it 'signed in as a moderator deletes the event' do
      sign_in mod
      delete "/api/1/events/#{e.id}"

      expect(response.code).to eq '200'

      expect(Event.where(id: e.id).first).to be_nil
    end

    it 'signed in as the other guy responds with a 401 status code and unauthorized message' do
      sign_in otherguy
      delete "/api/1/events/#{e.id}"

      expect(response.code).to eq '403'

      resp = JSON.parse(response.body)

      expect(resp['error']).to eq 'forbidden'
      expect(resp['error_description']).to eq 'The action you requested was forbidden.'

      expect(Event.where(id: e.id).first).to be
    end

    it 'not signed in replies with a 401 and unauthorized message' do
      delete "/api/1/events/#{e.id}"

      expect(response.code).to eq '401'

      resp = JSON.parse(response.body)

      expect(resp['error']).to eq 'unauthenticated'
      expect(resp['error_description']).to eq 'This action requires authentication to continue.'

      expect(Event.where(id: e.id).first).to be
    end
  end
end
