describe 'GET /api/v0/markets/:id/vendors' do
  # Happy Path
  it 'sends a list of vendors for a specific market' do
    market = create(:market)
    vendors = create_list(:vendor, 3, markets: [market])

    get "/api/v0/markets/#{market.id}/vendors"

    expect(response).to have_http_status(200)

    vendor_data = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(vendor_data.count).to eq(3)

    vendor_data.each do |vendor|
      expect(vendor).to have_key(:id)
      expect(vendor[:id]).to be_a(String)

      expect(vendor).to have_key(:type)
      expect(vendor[:type]).to eq('vendors')

      expect(vendor).to have_key(:attributes)

      attributes = vendor[:attributes]

      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)

      expect(attributes).to have_key(:description)
      expect(attributes[:description]).to be_a(String)

      expect(attributes).to have_key(:contact_name)
      expect(attributes[:contact_name]).to be_a(String)

      expect(attributes).to have_key(:contact_phone)
      expect(attributes[:contact_phone]).to be_a(String)

      expect(attributes).to have_key(:credit_accepted)
      expect(attributes[:credit_accepted]).to be_in([true, false])
    end
  end

  # Sad Path
  it 'returns a 404 error if the market does not exist' do
    get '/api/v0/markets/123123123123123/vendors'

    expect(response).to have_http_status(404)

    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to eq('Couldn\'t find Market with \'id\'=123123123123123')
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
