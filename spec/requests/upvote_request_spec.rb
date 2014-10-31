require 'spec_helper'

def sign_in(user)
  post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password
end

describe 'Upvote Request' do
  let(:user) { create :user }
  let(:event) { create :event }

  let(:sherlock) { create :user }
  let(:john) { create :user }
  let(:mycroft) { create :user }

  before(:each) do
    sign_in(user)
    event.add_upvote(sherlock)
    event.add_upvote(john)
    event.add_upvote(mycroft)
    event.save
  end

  describe 'GET /api/1/events/{id}/upvote' do
    it 'should be able to get a count of all upvotes on an event' do
      get "/api/1/events/#{event.id}/upvote"

      resp = JSON.parse(response.body)['response']

      expect(resp['upvote_count']).to eq 3
    end

    it 'it should indicate that the user has upvoted on this event' do
      post "/api/1/events/#{event.id}/upvote"
      get "/api/1/events/#{event.id}/upvote"

      resp = JSON.parse(response.body)['response']

      expect(resp['upvoted']).to be
    end

    it 'should indicate that the user has not upvoted on this event' do
      get "/api/1/events/#{event.id}/upvote"

      resp = JSON.parse(response.body)['response']

      expect(resp['upvoted']).not_to be
    end
  end

  describe 'POST /api/1/events/{id}/upvote' do
    it 'should be able to mark the event as upvoted for a user' do
      post "/api/1/events/#{event.id}/upvote"

      resp = JSON.parse(response.body)['response']

      expect(resp['upvote_count']).to eq 4
      expect(resp['upvoted']).to be
    end

    it 'should not double upvote the event and should reply with a 422 status code' do
      post "/api/1/events/#{event.id}/upvote"
      post "/api/1/events/#{event.id}/upvote"

      expect(response.status).to eq 422

      resp = JSON.parse(response.body)

      expect(resp['error']).to eq 'already_upvoted'
      expect(resp['error_message']).to eq 'You have already upvoted for this event once.'
    end
  end

  describe 'DELETE /api/1/events/{id}/upvote' do
    it 'should be able to downvote the event for a user that has previously been upvoted' do
      post "/api/1/events/#{event.id}/upvote"
      delete "/api/1/events/#{event.id}/upvote"
      
      expect(response.status).to eq 200

      resp = JSON.parse(response.body)['response']

      expect(resp['upvote_count']).to eq 3
      expect(resp['upvoted']).not_to be
    end

    it 'should reply with a 422 status code and not downvote an event when it has not been upvoted' do
      delete "/api/1/events/#{event.id}/upvote"
      
      expect(response.status).to eq 422

      resp = JSON.parse(response.body)

      expect(resp['error']).to eq 'not_upvoted'
      expect(resp['error_message']).to eq 'You have not upvoted on this event previously.'
    end
  end
end
