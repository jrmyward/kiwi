require 'spec_helper'

describe 'Subkasts Requests' do
  describe 'GET /subkasts' do
    before(:each) do
      create :education_subkast
      create :sports_subkast
      create :movies_subkast
    end

    it 'should be able to return a list of subkasts' do
      get '/api/1/subkasts'

      pagination = JSON.parse(response.body)['pagination']
      resp = JSON.parse(response.body)['response']

      expect(resp[0]['code']).to eq 'EDU'
      expect(resp[0]['name']).to eq 'Education'
      expect(resp[0]['slug']).to eq 'education'

      expect(resp[1]['code']).to eq 'SE'
      expect(resp[1]['name']).to eq 'Sports'
      expect(resp[1]['slug']).to eq 'sports'

      expect(resp[2]['code']).to eq 'TVM'
      expect(resp[2]['name']).to eq 'Movies'
      expect(resp[2]['slug']).to eq 'movies'

      expect(pagination['previous']).to be_nil
      expect(pagination['next']).to be_nil
      expect(pagination['current']).to be 1
      expect(pagination['count']).to be 3
      expect(pagination['pages']).to be 1
    end
  end
end
