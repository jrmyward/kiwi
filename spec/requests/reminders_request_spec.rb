require 'spec_helper'

def sign_in(user)
  post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password
end

describe 'Reminders Requests' do
  describe 'GET /api/1/events/{id}/reminders' do
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
        expect(resp['error_description']).to eq 'Could not find the event to lookup reminders.'
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
    it 'should be able to create a reminder for a user on an event' do

    end

    it 'should return a 422 status code and error message if an invalid reminder type is provided' do

    end
  end

  describe 'DELETE /api/1/events/{id}/reminders/{id}' do

  end
end
