require 'rails_helper'

# Get All Markets
describe 'GET /api/v0/markets' do
  # Happy Path
  it 'sends a list of markets' do
    create_list(:market, 3).each do |market|
      create_list(:vendor, 2, markets: [market])
    end

    get '/api/v0/markets'

    expect(response).to be_successful

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_response[:data].count).to eq(3)

    parsed_response[:data].each do |market_data|
      expect(market_data).to have_key(:id)
      expect(market_data[:id]).to be_an(String)

      expect(market_data).to have_key(:attributes) # Check for attributes in market_data

      attributes = market_data[:attributes] # Use attributes from market_data

      expect(attributes).to have_key(:street)
      expect(attributes[:street]).to be_a(String)

      expect(attributes).to have_key(:city)
      expect(attributes[:city]).to be_a(String)

      expect(attributes).to have_key(:county)
      expect(attributes[:county]).to be_a(String)

      expect(attributes).to have_key(:state)
      expect(attributes[:state]).to be_a(String)

      expect(attributes).to have_key(:zip)
      expect(attributes[:zip]).to be_a(String)

      expect(attributes).to have_key(:lat)
      expect(attributes[:lat]).to be_a(String)

      expect(attributes).to have_key(:lon)
      expect(attributes[:lon]).to be_a(String)

      # Test Vendor Count
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
  it 'sends a single market by id' do
    market = create(:market)
    create_list(:vendor, 1, markets: [market])

    get "/api/v0/markets/#{market.id}"

    expect(response).to have_http_status(200)

    market_data = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(market_data[:id].to_i).to eq(market.id)
    expect(market_data[:attributes][:name]).to be_a(String)
    expect(market_data[:attributes][:street]).to be_a(String)
    expect(market_data[:attributes][:city]).to be_a(String)
    expect(market_data[:attributes][:county]).to be_a(String)
    expect(market_data[:attributes][:state]).to be_a(String)
    expect(market_data[:attributes][:zip]).to be_a(String)
    expect(market_data[:attributes][:lat]).to be_a(String)
    expect(market_data[:attributes][:lon]).to be_a(String)

    # Testing Vendor Count is correct
    expect(market_data[:attributes][:vendor_count]).to be_an(Integer)
    expect(market_data[:attributes][:vendor_count]).to eq(1)
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
