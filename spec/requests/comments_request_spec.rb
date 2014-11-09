require 'spec_helper'

def sign_in(user)
  post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password
end

describe 'Comments Requests' do
  let(:u1) { create :user }
  let(:u2) { create :user }
  let(:u3) { create :user }
  let(:u4) { create :user }

  let(:event) { create :event }

  let!(:c1) { event.comment('Event looking good!', u1) }
  let!(:c2) { event.comment('Event looking great!', u1) }
  let!(:r1) { c1.reply('Comment looking good!', u1) }
  let!(:r2) { r1.reply('Reply looking good!', u2) }

  before(:each) do
    c1.add_upvote(u2)
    c1.add_upvote(u3)
    c1.add_downvote(u4)
    c2.add_downvote(u2)

    r2.add_upvote(u2)
  end

  describe 'GET /api/1/events/{id}/comments' do
    context 'not signed in' do
      it 'responds with a list of comments for an event' do
        get "/api/1/events/#{event.id}/comments"

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp[0]['message']).to eq 'Event looking good!'
        expect(resp[0]['by']).to eq u1.username
        expect(resp[0]['upvote_count']).to eq 2
        expect(resp[0]['upvoted']).to be_nil
        expect(resp[0]['downvote_count']).to eq 1
        expect(resp[0]['downvoted']).to be_nil

        expect(resp[0]['replies'][0]['message']).to eq 'Comment looking good!'
        expect(resp[0]['replies'][0]['by']).to eq u1.username
        expect(resp[0]['replies'][0]['upvote_count']).to eq 0
        expect(resp[0]['replies'][0]['upvoted']).to be_nil
        expect(resp[0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['downvoted']).to be_nil

        expect(resp[0]['replies'][0]['replies'][0]['message']).to eq 'Reply looking good!'
        expect(resp[0]['replies'][0]['replies'][0]['by']).to eq u2.username
        expect(resp[0]['replies'][0]['replies'][0]['upvote_count']).to eq 1
        expect(resp[0]['replies'][0]['replies'][0]['upvoted']).to be_nil
        expect(resp[0]['replies'][0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['replies'][0]['downvoted']).to be_nil

        expect(resp[1]['message']).to eq 'Event looking great!'
        expect(resp[1]['by']).to eq u1.username
        expect(resp[1]['upvote_count']).to eq 0
        expect(resp[1]['upvoted']).to be_nil
        expect(resp[1]['downvote_count']).to eq 1
        expect(resp[1]['downvoted']).to be_nil
      end

      it 'responds with a 422 status code and an error message when the requested event is missing' do
        get '/api/1/events/ZZZ/comments'

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'event_not_found'
        expect(resp['error_description']).to eq 'Could not find the event.'
      end
    end

    context 'signed in' do
      before(:each) do
        sign_in(u2)
      end

      it 'responds with a list of comments for an event including upvoted and downvoted booleans' do
        get "/api/1/events/#{event.id}/comments"

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp[0]['message']).to eq 'Event looking good!'
        expect(resp[0]['by']).to eq u1.username
        expect(resp[0]['upvote_count']).to eq 2
        expect(resp[0]['upvoted']).to be
        expect(resp[0]['downvote_count']).to eq 1
        expect(resp[0]['downvoted']).not_to be

        expect(resp[0]['replies'][0]['message']).to eq 'Comment looking good!'
        expect(resp[0]['replies'][0]['by']).to eq u1.username
        expect(resp[0]['replies'][0]['upvote_count']).to eq 0
        expect(resp[0]['replies'][0]['upvoted']).not_to be
        expect(resp[0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['downvoted']).not_to be

        expect(resp[0]['replies'][0]['replies'][0]['message']).to eq 'Reply looking good!'
        expect(resp[0]['replies'][0]['replies'][0]['by']).to eq u2.username
        expect(resp[0]['replies'][0]['replies'][0]['upvote_count']).to eq 1
        expect(resp[0]['replies'][0]['replies'][0]['upvoted']).to be
        expect(resp[0]['replies'][0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['replies'][0]['downvoted']).not_to be

        expect(resp[1]['message']).to eq 'Event looking great!'
        expect(resp[1]['by']).to eq u1.username
        expect(resp[1]['upvote_count']).to eq 0
        expect(resp[1]['upvoted']).not_to be
        expect(resp[1]['downvote_count']).to eq 1
        expect(resp[1]['downvoted']).to be
      end
    end
  end

  describe 'POST /api/1/events/{id}/comments' do
    context 'signed in' do
      before(:each) do
        sign_in(u2)
      end

      it 'creates a comment on an event' do
        post "/api/1/events/#{event.id}/comments", { message: 'Something great is happening!' }

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp[0]['message']).to eq 'Event looking good!'
        expect(resp[0]['by']).to eq u1.username
        expect(resp[0]['upvote_count']).to eq 2
        expect(resp[0]['upvoted']).to be
        expect(resp[0]['downvote_count']).to eq 1
        expect(resp[0]['downvoted']).not_to be

        expect(resp[0]['replies'][0]['message']).to eq 'Comment looking good!'
        expect(resp[0]['replies'][0]['by']).to eq u1.username
        expect(resp[0]['replies'][0]['upvote_count']).to eq 0
        expect(resp[0]['replies'][0]['upvoted']).not_to be
        expect(resp[0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['downvoted']).not_to be

        expect(resp[0]['replies'][0]['replies'][0]['message']).to eq 'Reply looking good!'
        expect(resp[0]['replies'][0]['replies'][0]['by']).to eq u2.username
        expect(resp[0]['replies'][0]['replies'][0]['upvote_count']).to eq 1
        expect(resp[0]['replies'][0]['replies'][0]['upvoted']).to be
        expect(resp[0]['replies'][0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['replies'][0]['downvoted']).not_to be

        expect(resp[1]['message']).to eq 'Event looking great!'
        expect(resp[1]['by']).to eq u1.username
        expect(resp[1]['upvote_count']).to eq 0
        expect(resp[1]['upvoted']).not_to be
        expect(resp[1]['downvote_count']).to eq 1
        expect(resp[1]['downvoted']).to be

        expect(resp[2]['message']).to eq 'Something great is happening!'
        expect(resp[2]['by']).to eq u2.username
        expect(resp[2]['upvote_count']).to eq 0
        expect(resp[2]['upvoted']).not_to be
        expect(resp[2]['downvote_count']).to eq 0
        expect(resp[2]['downvoted']).not_to be
      end

      it 'responds with a 422 status code and an error message when trying to comment on an event that does not exist' do
        post '/api/1/events/ZZZ/comments', { message: 'Something great is happening!' }

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'event_not_found'
        expect(resp['error_description']).to eq 'Could not find the event.'
      end

      it 'creates a reply (comment on a comment)' do
        post "/api/1/events/#{event.id}/comments", { message: 'That reply was pretty cool.', reply_to: c2.id }

        expect(response.code).to eq '200'

        resp = JSON.parse(response.body)['response']

        expect(resp[0]['message']).to eq 'Event looking good!'
        expect(resp[0]['by']).to eq u1.username
        expect(resp[0]['upvote_count']).to eq 2
        expect(resp[0]['upvoted']).to be
        expect(resp[0]['downvote_count']).to eq 1
        expect(resp[0]['downvoted']).not_to be

        expect(resp[0]['replies'][0]['message']).to eq 'Comment looking good!'
        expect(resp[0]['replies'][0]['by']).to eq u1.username
        expect(resp[0]['replies'][0]['upvote_count']).to eq 0
        expect(resp[0]['replies'][0]['upvoted']).not_to be
        expect(resp[0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['downvoted']).not_to be

        expect(resp[0]['replies'][0]['replies'][0]['message']).to eq 'Reply looking good!'
        expect(resp[0]['replies'][0]['replies'][0]['by']).to eq u2.username
        expect(resp[0]['replies'][0]['replies'][0]['upvote_count']).to eq 1
        expect(resp[0]['replies'][0]['replies'][0]['upvoted']).to be
        expect(resp[0]['replies'][0]['replies'][0]['downvote_count']).to eq 0
        expect(resp[0]['replies'][0]['replies'][0]['downvoted']).not_to be

        expect(resp[1]['message']).to eq 'Event looking great!'
        expect(resp[1]['by']).to eq u1.username
        expect(resp[1]['upvote_count']).to eq 0
        expect(resp[1]['upvoted']).not_to be
        expect(resp[1]['downvote_count']).to eq 1
        expect(resp[1]['downvoted']).to be

        expect(resp[1]['replies'][0]['message']).to eq 'That reply was pretty cool.'
        expect(resp[1]['replies'][0]['by']).to eq u2.username
        expect(resp[1]['replies'][0]['upvote_count']).to eq 0
        expect(resp[1]['replies'][0]['upvoted']).not_to be
        expect(resp[1]['replies'][0]['downvote_count']).to eq 0
        expect(resp[1]['replies'][0]['downvoted']).not_to be
      end

      it 'responds with a 422 status code and an error message when trying to comment on a comment that does not exist' do
        post "/api/1/events/#{event.id}/comments", { message: 'Something great is happening!', reply_to: 'ZZZ' }

        expect(response.code).to eq '422'

        resp = JSON.parse(response.body)

        expect(resp['error']).to eq 'comment_not_found'
        expect(resp['error_description']).to eq 'Could not find the comment to reply to.'
      end
    end

    context 'not signed in' do

    end
  end

  describe 'POST /api/1/comments/{id}/upvote' do
    context 'signed in' do
      it 'upvotes a no voted comment' do

      end

      it 'removes a downvote from a downvoted comment' do

      end

      it 'responds with a 422 status code and error message on an upvoted comment' do

      end
    end

    context 'not signed in' do

    end
  end

  describe 'DELETE /api/1/comments/{id}/upvote' do
    context 'signed in' do
      it 'removes an upvote from an upvoted event' do

      end

      it 'responds with a 422 status code and error message on a comment that has not been upvoted' do

      end
    end

    context 'not signed in' do

    end
  end

  describe 'POST /api/1/comments/{id}/downvote' do
    context 'signed in' do
      it 'downvotes a no voted comment' do

      end

      it 'removes an upvote from an upvoted event' do

      end

      it 'responds with a 422 status code and error message on a downvote comment' do

      end
    end

    context 'not signed in' do

    end
  end

  describe 'DELETE /api/1/comments/{id}/downvote' do
    it 'removes a downvote from a downvoted event' do

    end

    it 'replies with a 422 status code and error message on a comment that has not been downvote' do

    end
  end

  describe 'DELETE /api/1/comments/{id}' do
    it 'mutes a comment as a moderator' do

    end

    it 'deletes a comment as a user' do

    end

    it 'provides a 404 when the subject comment was not found' do

    end
  end
end
