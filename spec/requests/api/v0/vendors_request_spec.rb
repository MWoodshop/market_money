require 'rails_helper'

# Get One Vendor
describe 'GET /api/v0/vendors/:id' do
  # Happy Path
  it 'sends one vendor by id' do
    vendor = create(:vendor)

    get "/api/v0/vendors/#{vendor.id}"

    expect(response).to have_http_status(200)

    vendor_data = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(vendor_data[:id].to_i).to eq(vendor.id)
    expect(vendor_data[:type]).to eq('vendor')
    expect(vendor_data[:attributes][:name]).to eq(vendor.name)
    expect(vendor_data[:attributes][:description]).to eq(vendor.description)
    expect(vendor_data[:attributes][:contact_name]).to eq(vendor.contact_name)
    expect(vendor_data[:attributes][:contact_phone]).to eq(vendor.contact_phone)
    expect(vendor_data[:attributes][:credit_accepted]).to eq(vendor.credit_accepted)
  end

  # Sad Path
  it 'returns a 404 error if vendor does not exist' do
    get '/api/v0/vendors/12345678901'

    expect(response).to have_http_status(404)

    errors = JSON.parse(response.body, symbolize_names: true)[:errors]
    expect(errors.first[:detail]).to eq("Couldn't find Vendor with 'id'=12345678901")
  end

  # Exception Handling
  it 'returns a 500 error when something goes wrong on the server' do
    allow(Vendor).to receive(:find).and_raise(StandardError.new('Something went wrong'))

    get '/api/v0/vendors/123'

    expect(response).to have_http_status(500)
  end
end
