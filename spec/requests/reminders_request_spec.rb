require 'spec_helper'

def sign_in(user)
  post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password
end

describe 'Reminders Requests' do
  let!(:e1) { create :event }
  let!(:e2) { create :event }

  let!(:u1) { create :user }
  let!(:u2) { create :user }

  let!(:r2) { create :reminder, :one_h_before, event: e1, user: u1 }
  let!(:r3) { create :reminder, :four_h_before, event: e1, user: u1 }
  let!(:r4) { create :reminder, :one_d_before, event: e1, user: u1 }
  let!(:r1) { create :reminder, :fifteen_m_before, event: e1, user: u1 }

  let!(:r5) { create :reminder, :fifteen_m_before, event: e1, user: u2 }
  let!(:r6) { create :reminder, :fifteen_m_before, event: e2, user: u1 }

  describe 'GET /api/1/events/{id}/reminders' do
    context 'signed in' do
      before(:each) do
        sign_in(u1)
      end

      it 'should be able to a get a list of all the reminders set on an event for a user ordered by interval length' do
        get "/api/1/events/#{e1.id}/reminders"

        resp = JSON.parse(response.body)['response']

        expect(response.code).to eq '200'

        expect(resp[0]['interval']).to eq '15m'
        expect(resp[1]['interval']).to eq '1h'
        expect(resp[2]['interval']).to eq '4h'
        expect(resp[3]['interval']).to eq '1d'
      end

      it 'should respond with an error and a 422 status code when the event could not be found' do
        get '/api/1/events/ZZZ/reminders'

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'event_not_found'
        expect(resp['error_description']).to eq 'Could not find the event.'
      end
    end

    context 'not signed in' do
      it 'should reponse with an error and a 401 status code when the user is not signed in' do
        get "/api/1/events/#{e1.id}/reminders"

        resp = JSON.parse(response.body)

        expect(response.code).to eq '401'

        expect(resp['error']).to eq 'unauthenticated'
        expect(resp['error_description']).to eq 'This action requires authentication to continue.'
      end
    end
  end

  describe 'POST /api/1/events/{id}/reminders' do
    context 'signed in' do
      before(:each) do
        sign_in(u1)
      end

      it 'should be able to create a reminder for a user on an event' do
        post "/api/1/events/#{e2.id}/reminders", { interval: '4h' }

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp[0]['interval']).to eq '15m'
        expect(resp[1]['interval']).to eq '4h'
      end

      it 'should return a 422 status code and error message if an invalid reminder type is provided' do
        post "/api/1/events/#{e1.id}/reminders", { interval: '16m' }

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'invalid_reminder_interval'
        expect(resp['error_description']).to eq 'Provided reminder interval does not exist.'
      end

      it 'should return a 422 status code and error message if this reminder is already created' do
        post "/api/1/events/#{e1.id}/reminders", { interval: '15m' }

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'reminder_already_set'
        expect(resp['error_description']).to eq 'A reminder at this interval is already set for this event.'
      end

      it 'should return a 422 status code and error message if a non existant event is provided' do
        post "/api/1/events/ZZZ/reminders", { interval: '15m' }.to_json

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'event_not_found'
        expect(resp['error_description']).to eq 'Could not find the event.'
      end
    end

    it 'should return a 401 status code and error message if the user is not logged in' do
      post "/api/1/events/#{e2.id}/reminders", { interval: '4h' }

      expect(response.code).to eq '401'

      resp = JSON.parse(response.body)

      expect(resp['error']).to eq 'unauthenticated'
      expect(resp['error_description']).to eq 'This action requires authentication to continue.'
    end
  end

  describe 'DELETE /api/1/events/{id}/reminders/{id}' do
    context 'signed in' do
      before(:each) do
        sign_in(u1)
      end

      it 'removes the reminder' do
        delete "/api/1/events/#{e1.id}/reminders/1h"

        expect(response.code).to eq '200'

        reminder_intervals = e1.reminders_for_user(u1).map(&:time_to_event)

        expect(reminder_intervals).not_to include('1h')
      end

      it 'returns a 422 status code and an error message when the event could not be found' do
        delete '/api/1/events/ZZZ/reminders/1h'

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'event_not_found'
        expect(resp['error_description']).to eq 'Could not find the event.'
      end

      it 'returns a 404 status code and error message when the reminder is not set on the event' do
        delete "/api/1/events/#{e2.id}/reminders/1d"

        expect(response.code).to eq '404'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'missing_reminder'
        expect(resp['error_description']).to eq 'Event does not have this reminder interval set.'
      end

      it 'returns a 404 status code and error message when the reminder is not a valid interval' do
        delete "/api/1/events/#{e1.id}/reminders/2d"

        expect(response.code).to eq '404'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'missing_reminder'
        expect(resp['error_description']).to eq 'Event does not have this reminder interval set.'
      end
    end

    context 'not signed in' do
      it 'responds with a 401 status code and error message if the user is not logged in' do
        delete "/api/1/events/#{e2.id}/reminders/4h"

        expect(response.code).to eq '401'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'unauthenticated'
        expect(resp['error_description']).to eq 'This action requires authentication to continue.'
      end
    end
  end
end
