require 'spec_helper'

describe 'Comments Requests' do
  describe 'GET /events/{id}/comments' do
    it 'should be able to get a list of comments for an event' do

    end
  end

  describe 'POST /events/{id}/comments' do
    it 'should be able to create an event on a comment' do

    end

    it 'should be able to create a reply' do

    end

    it 'should provide a 422 status code and error message when trying to reply to a missing comment' do

    end
  end

  describe 'POST /comments/{id}/upvote' do
    it 'should be able to upvote a no voted comment' do

    end

    it 'should remove a downvote from a downvoted comment' do

    end

    it 'should reply with a 422 status code and error message on an upvoted comment' do

    end
  end

  describe 'DELETE /comments/{id}/upvote' do
    it 'should be able to remove an upvote from an upvoted event' do

    end

    it 'should reply with a 422 status code and error message on a comment that has not been upvoted' do

    end
  end

  describe 'POST /comments/{id}/downvote' do
    it 'should be able to downvote a no voted comment' do

    end

    it 'should remove an upvote from an upvoted event' do

    end

    it 'should reply with a 422 status code and error message on a downvote comment' do

    end
  end

  describe 'DELETE /comments/{id}/downvote' do
    it 'should be able to remove a downvote from a downvoted event' do

    end

    it 'should reply with a 422 status code and error message on a comment that has not been downvote' do

    end
  end

  describe 'DELETE /comments/{id}' do
    it 'should be able to mute a comment as a moderator' do

    end

    it 'should be able to delete a comment' do

    end

    it 'should provide a 404 when the subject comment was not found' do

    end
  end
end
