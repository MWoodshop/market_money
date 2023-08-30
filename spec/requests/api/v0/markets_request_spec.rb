require 'rails_helper'

# Get All Markets
describe 'GET /api/v0/markets' do
  # Happy Path
  it 'sends a list of markets' do
    created_markets = create_list(:market, 3)
    created_markets.each do |market|
      create_list(:vendor, 2, markets: [market])
    end

    get '/api/v0/markets'

    expect(response).to have_http_status(200)

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    # Validate the number of returned markets
    expect(parsed_response[:data].count).to eq(3)

    returned_market_ids = parsed_response[:data].map { |market| market[:id].to_i }
    expected_market_ids = created_markets.map(&:id)

    expect(returned_market_ids).to match_array(expected_market_ids)

    # Iterate through each returned market
    parsed_response[:data].each do |returned_market|
      corresponding_market = created_markets.find { |market| market.id == returned_market[:id].to_i }

      # Validate keys and actual data
      expect(returned_market).to have_key(:id)
      expect(returned_market[:id].to_i).to eq(corresponding_market.id)

      expect(returned_market).to have_key(:attributes)

      attributes = returned_market[:attributes]

      expect(attributes[:street]).to eq(corresponding_market.street)
      expect(attributes[:city]).to eq(corresponding_market.city)
      expect(attributes[:county]).to eq(corresponding_market.county)
      expect(attributes[:state]).to eq(corresponding_market.state)
      expect(attributes[:zip]).to eq(corresponding_market.zip)
      expect(attributes[:lat]).to eq(corresponding_market.lat)
      expect(attributes[:lon]).to eq(corresponding_market.lon)

      # Validate vendor count
      expect(attributes).to have_key(:vendor_count)
      expect(attributes[:vendor_count]).to be_an(Integer)
      expect(attributes[:vendor_count]).to eq(2)
    end
  end

  # Sad Path
  it 'returns an empty array if no markets exist' do
    get '/api/v0/markets'

    expect(response).to be_successful
    parsed_response = JSON.parse(response.body, symbolize_names: true)
    expect(parsed_response[:data]).to eq([])
  end

  # Exception Handling
  it 'returns a 500 error when something goes wrong on the server' do
    allow(Market).to receive(:all).and_raise(StandardError.new('Something went wrong'))

    get '/api/v0/markets'

    expect(response).to have_http_status(500)
    parsed_response = JSON.parse(response.body, symbolize_names: true)
    expect(parsed_response[:errors].first[:detail]).to eq('Something went wrong')
  end
end

# Get One Market by ID
describe 'GET /api/v0/markets/:id' do
  # Happy Path
  it 'sends a single market by id' do
    market = create(:market)
    create_list(:vendor, 1, markets: [market])

    get "/api/v0/markets/#{market.id}"

    expect(response).to have_http_status(200)

    market_data = JSON.parse(response.body, symbolize_names: true)[:data]

    # Validate ID and type
    expect(market_data[:id].to_i).to eq(market.id)

    # Validate attributes
    attributes = market_data[:attributes]

    expect(attributes[:name]).to eq(market.name)
    expect(attributes[:street]).to eq(market.street)
    expect(attributes[:city]).to eq(market.city)
    expect(attributes[:county]).to eq(market.county)
    expect(attributes[:state]).to eq(market.state)
    expect(attributes[:zip]).to eq(market.zip)
    expect(attributes[:lat]).to eq(market.lat)
    expect(attributes[:lon]).to eq(market.lon)

    # Validate vendor count
    expect(attributes[:vendor_count]).to be_an(Integer)
    expect(attributes[:vendor_count]).to eq(1)
  end

  # Sad Path
  it 'returns a 404 error if market does not exist' do
    get '/api/v0/markets/123123123123123123123123'

    expect(response).to have_http_status(404)

    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to include("Couldn't find Market with 'id'=123123123123123123123123")
  end

  # Exception Handling
  it 'returns a 500 error when something goes wrong on the server' do
    allow(Market).to receive(:find).and_raise(StandardError.new('Something went wrong'))

    get '/api/v0/markets/123'

    expect(response).to have_http_status(500)
  end
end
