# Get All Vendors for a Market
describe 'GET /api/v0/markets/:id/vendors' do
  # Happy Path
  it 'sends a list of vendors for a specific market' do
    market = create(:market)
    vendors = create_list(:vendor, 3, markets: [market])

    get "/api/v0/markets/#{market.id}/vendors"

    expect(response).to have_http_status(200)

    vendor_data = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(vendor_data.count).to eq(3)

    returned_vendor_ids = vendor_data.map { |vendor| vendor[:id].to_i }
    expected_vendor_ids = vendors.map(&:id)

    expect(returned_vendor_ids).to match_array(expected_vendor_ids)

    vendor_data.each do |returned_vendor|
      corresponding_vendor = vendors.find { |vendor| vendor.id == returned_vendor[:id].to_i }

      expect(returned_vendor).to have_key(:id)
      expect(returned_vendor[:id].to_i).to eq(corresponding_vendor.id)

      expect(returned_vendor).to have_key(:type)
      expect(returned_vendor[:type]).to eq('vendor')

      expect(returned_vendor).to have_key(:attributes)

      attributes = returned_vendor[:attributes]

      expect(attributes[:name]).to eq(corresponding_vendor.name)
      expect(attributes[:description]).to eq(corresponding_vendor.description)
      expect(attributes[:contact_name]).to eq(corresponding_vendor.contact_name)
      expect(attributes[:contact_phone]).to eq(corresponding_vendor.contact_phone)
      expect(attributes[:credit_accepted]).to eq(corresponding_vendor.credit_accepted)
    end
  end

  # Sad Path
  it 'returns a 404 error if the market does not exist' do
    get '/api/v0/markets/123123123123123/vendors'

    expect(response).to have_http_status(404)

    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to eq("Couldn't find Market with 'id'=123123123123123")
  end

  # Exception Handling
  it 'returns a 500 error if something goes wrong on the server' do
    allow(Market).to receive(:find).and_raise(StandardError.new('Something went wrong'))

    get '/api/v0/markets/123/vendors'

    expect(response).to have_http_status(500)

    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to include('Something went wrong')
  end
end

# Create a Market Vendor
describe 'POST /api/v0/market_vendors' do
  # Happy Path
  it 'adds a vendor to a market with valid market and vendor IDs' do
    market = create(:market)
    vendor = create(:vendor)

    post '/api/v0/market_vendors', params: { market_id: market.id, vendor_id: vendor.id }

    expect(response).to have_http_status(201)
  end

  # Sad Path
  it 'returns a 404 error when invalid market or vendor ID is provided' do
    post '/api/v0/market_vendors', params: { market_id: 123_123_123_123_123, vendor_id: 123_123_123_123_123 }
    expect(response).to have_http_status(404)
  end

  it 'returns 422 when a duplicate MarketVendor is created' do
    market = create(:market)
    vendor = create(:vendor)
    MarketVendor.create(market:, vendor:)

    post '/api/v0/market_vendors', params: { market_id: market.id, vendor_id: vendor.id }
    expect(response).to have_http_status(422)
  end

  # Exception Handling
  it 'returns a 500 error when something goes wrong on the server' do
    allow(Market).to receive(:find).and_raise(StandardError.new('Something went wrong'))

    post '/api/v0/market_vendors', params: { market_id: 1, vendor_id: 1 }
    expect(response).to have_http_status(500)
  end
end
