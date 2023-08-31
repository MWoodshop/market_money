require 'rails_helper'

RSpec.describe 'Cash Dispensers', type: :request do
  describe 'GET /api/v0/markets/:id/nearest_atms', vcr: { cassette_name: 'tomtom/atms' } do
    # Happy path
    it 'returns a list of ATMs sorted by distance' do
      market = create(:market, lat: 35.07904, lon: -106.60068)

      get api_v0_market_nearest_atms_path(market.id),
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }

      expect(response.status).to eq(200)

      json_response = JSON.parse(response.body)
      expect(json_response['data'].size).to be > 0 # To confirm that data array is not empty
    end

    # Sad Path
    it 'returns a 404 status and an error message' do
      get api_v0_market_nearest_atms_path('invalid-id'),
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }

      expect(response.status).to eq(404)

      json_response = JSON.parse(response.body)

      expect(json_response['errors'][0]['detail']).to eq("Couldn't find Market with 'id'=invalid-id")
    end

    # Handling exceptions
    it 'returns a 500 status and an error message' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(StandardError.new('Internal Server Error'))

      market = create(:market, lat: 35.07904, lon: -106.60068)
      get api_v0_market_nearest_atms_path(market.id),
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }

      expect(response.status).to eq(500)
      json_response = JSON.parse(response.body)

      expect(json_response['errors'][0]['detail']).to eq('Internal Server Error')
    end
  end
end
