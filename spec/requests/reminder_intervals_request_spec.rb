require 'spec_helper'

describe 'Reminder Intervals Request' do
  describe 'GET /reminder_intervals' do
    it 'should be able to get a list of request intervals' do
      get '/api/1/reminder_intervals'

      resp = JSON.parse(response.body)['response']

      expect(resp[0]['interval']).to eq '15m'
      expect(resp[1]['interval']).to eq '1h'
      expect(resp[2]['interval']).to eq '4h'
      expect(resp[3]['interval']).to eq '1d'
    end
  end
end
