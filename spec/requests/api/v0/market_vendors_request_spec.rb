require 'rails_helper'

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
  it 'returns a 404 error when an invalid vendor ID is provided' do
    market = create(:market)
    invalid_vendor_id = 123_123_123_123_123

    post '/api/v0/market_vendors', params: { market_id: market.id, vendor_id: invalid_vendor_id }

    expect(response).to have_http_status(404)
    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to eq("Couldn't find Vendor with 'id'=#{invalid_vendor_id}")
  end

  it 'returns errors with full_messages when a MarketVendor is invalid' do
    market = create(:market)
    vendor = create(:vendor)

    # Create a MarketVendor that would violate the uniqueness constraints
    MarketVendor.create(market:, vendor:)

    post '/api/v0/market_vendors', params: { market_id: market.id, vendor_id: vendor.id }

    expect(response).to have_http_status(:unprocessable_entity)

    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body).to have_key(:errors)
    expect(response_body[:errors]).to include(detail: 'This vendor is already associated with this market')
  end

  # Exception Handling
  it 'returns a 500 error when something goes wrong while finding the vendor' do
    market = create(:market)
    allow(Vendor).to receive(:find).and_raise(StandardError.new('Something went wrong'))

    post '/api/v0/market_vendors', params: { market_id: market.id, vendor_id: 1 }

    expect(response).to have_http_status(500)
    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to include('Something went wrong')
  end

  it 'returns a 500 error when something goes wrong while finding the MarketVendor' do
    market = create(:market)
    vendor = create(:vendor)
    allow(MarketVendor).to receive(:find_by).and_raise(StandardError.new('Something really went wrong'))

    delete '/api/v0/market_vendors', params: { market_vendor: { market_id: market.id, vendor_id: vendor.id } },
                                     as: :json

    expect(response.status).to eq(500)
    expect(JSON.parse(response.body)['errors'][0]['detail']).to include('Something really went wrong')
  end
end

# Delete a Market Vendor
describe 'DELETE /api/v0/market_vendors' do
  # Happy Path
  it 'removes a vendor from a market with valid market and vendor IDs' do
    market = create(:market)
    vendor = create(:vendor)
    market_vendor = MarketVendor.create!(market:, vendor:)

    delete '/api/v0/market_vendors', params: { market_vendor: { market_id: market.id, vendor_id: vendor.id } },
                                     as: :json

    expect(response.status).to eq(204)
    expect(MarketVendor.exists?(market_id: market.id, vendor_id: vendor.id)).to be_falsey
  end

  it 'returns no_content status when destroying a valid market_vendor' do
    market = create(:market)
    vendor = create(:vendor)
    market_vendor = MarketVendor.create!(market:, vendor:)

    result = MarketVendorService.destroy_market_vendor(market_vendor)
    expect(result[:status]).to eq(:no_content)
  end

  # Sad Path
  it 'returns a 404 error when invalid market or vendor ID is provided' do
    non_existing_market_id = 4233
    non_existing_vendor_id = 11_520

    delete '/api/v0/market_vendors',
           params: { market_vendor: { market_id: non_existing_market_id, vendor_id: non_existing_vendor_id } }, as: :json

    expect(response.status).to eq(404)
    expect(JSON.parse(response.body)['errors'][0]).to eq("No MarketVendor with market_id=#{non_existing_market_id} AND vendor_id=#{non_existing_vendor_id} exists")
  end

  it 'returns internal_server_error status and error message when there is an error during destroy' do
    market_vendor = double('MarketVendor')
    allow(market_vendor).to receive(:destroy!).and_raise(StandardError.new('Some error'))

    result = MarketVendorService.destroy_market_vendor(market_vendor)
    expect(result[:status]).to eq(:internal_server_error)
    expect(result[:errors]).to include(detail: 'Some error')
  end

  # Exception Handling
  it 'returns 500 for internal server error' do
    market = create(:market)
    vendor = create(:vendor)

    allow_any_instance_of(MarketVendor).to receive(:destroy).and_raise('Something went wrong')

    market_vendor = MarketVendor.create!(market:, vendor:)
    delete '/api/v0/market_vendors', params: { market_vendor: { market_id: market.id, vendor_id: vendor.id } },
                                     as: :json

    expect(response.status).to eq(500)
    expect(JSON.parse(response.body)['errors'][0]['detail']).to eq('Something went wrong')
  end
end
