require 'rails_helper'

# Get All Markets
describe 'GET /api/v0/markets' do
  # Happy Path
  it 'sends a list of markets' do
    markets = create_list(:market, 3)
    markets.each do |market|
      create_list(:vendor, 2, markets: [market])
    end

    get '/api/v0/markets'

    expect(response).to be_successful

    markets = JSON.parse(response.body, symbolize_names: true)

    expect(markets.count).to eq(3)

    markets.each do |market|
      expect(market).to have_key(:id)
      expect(market[:id]).to be_an(Integer)

      expect(market).to have_key(:name)
      expect(market[:name]).to be_a(String)

      expect(market).to have_key(:street)
      expect(market[:street]).to be_a(String)

      expect(market).to have_key(:city)
      expect(market[:city]).to be_a(String)

      expect(market).to have_key(:county)
      expect(market[:county]).to be_a(String)

      expect(market).to have_key(:state)
      expect(market[:state]).to be_a(String)

      expect(market).to have_key(:zip)
      expect(market[:zip]).to be_a(String)

      expect(market).to have_key(:lat)
      expect(market[:lat]).to be_a(String)

      expect(market).to have_key(:lon)
      expect(market[:lon]).to be_a(String)

      # Test Vendor Count
      expect(market).to have_key(:vendor_count)
      expect(market[:vendor_count]).to be_an(Integer)
      expect(market[:vendor_count]).to eq(2)
    end
  end

  # Sad Path
  it 'returns an empty array if no markets exist' do
    get '/api/v0/markets'

    expect(response).to be_successful
    markets = JSON.parse(response.body, symbolize_names: true)

    expect(markets).to eq([])
  end

  # Exception Handling
  it 'returns a 500 error when something goes wrong on the server' do
    allow(Market).to receive(:all).and_raise(StandardError.new('Something went wrong'))

    get '/api/v0/markets'

    expect(response).to have_http_status(500)
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
