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

  # Create a Vendor
  describe 'POST /api/v0/vendors' do
    # Happy Path
    it 'creates a new vendor with all required attributes' do
      valid_attributes = attributes_for(:vendor)

      expect do
        post '/api/v0/vendors', params: { vendor: valid_attributes }
      end.to change(Vendor, :count).by(1)

      expect(response).to have_http_status(201)

      vendor_data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(vendor_data[:id].to_i).to eq(Vendor.last.id)
      expect(vendor_data[:type]).to eq('vendor')
      expect(vendor_data[:attributes][:name]).to eq(valid_attributes[:name])
      expect(vendor_data[:attributes][:description]).to eq(valid_attributes[:description])
      expect(vendor_data[:attributes][:contact_name]).to eq(valid_attributes[:contact_name])
      expect(vendor_data[:attributes][:contact_phone]).to eq(valid_attributes[:contact_phone])
      expect(vendor_data[:attributes][:credit_accepted]).to eq(valid_attributes[:credit_accepted])
    end

    # Sad Path
    it 'returns a 400 error if required attributes are missing' do
      invalid_attributes = attributes_for(:vendor, contact_name: nil, contact_phone: nil)

      post '/api/v0/vendors', params: { vendor: invalid_attributes }

      expect(response).to have_http_status(400)

      errors = JSON.parse(response.body, symbolize_names: true)[:errors]
      expect(errors).to include("Contact name can't be blank", "Contact phone can't be blank")
    end

    # Exception Handling
    it 'returns a 500 error when something goes wrong on the server' do
      allow(Vendor).to receive(:new).and_raise(StandardError.new('Something went wrong'))

      post '/api/v0/vendors',
           params: { vendor: { name: '', description: '', contact_name: '', contact_phone: '', credit_accepted: '' } }

      expect(response).to have_http_status(500)
    end
  end

  # Update a Vendor
  describe 'PATCH /api/v0/vendors/:id' do
    # Happy Path
    it 'updates an existing vendor with all required attributes' do
      vendor = create(:vendor)

      valid_attributes = attributes_for(:vendor)

      patch "/api/v0/vendors/#{vendor.id}", params: { vendor: valid_attributes }

      expect(response).to have_http_status(200)
    end

    it 'updates an existing vendor with some required attributes' do
      vendor = create(:vendor)

      valid_attributes = attributes_for(:vendor)

      patch "/api/v0/vendors/#{vendor.id}", params: { vendor: valid_attributes }

      expect(response).to have_http_status(200)
    end

    # Sad Path
    it 'returns a 400 error if required attributes are missing' do
      vendor = create(:vendor)

      invalid_attributes = attributes_for(:vendor, contact_name: nil, contact_phone: nil)

      patch "/api/v0/vendors/#{vendor.id}", params: { vendor: invalid_attributes }

      expect(response).to have_http_status(400)

      errors = JSON.parse(response.body, symbolize_names: true)[:errors]
      expect(errors).to include("Contact phone can't be blank")
    end

    it 'returns a 404 error if vendor does not exist' do
      non_existent_vendor_id = 123_123_123_123
      valid_attributes = attributes_for(:vendor)

      put "/api/v0/vendors/#{non_existent_vendor_id}", params: { vendor: valid_attributes }

      expect(response.status).to eq(404)
      json = JSON.parse(response.body)

      expect(json['errors']).to be_present
      expect(json['errors'].first['detail']).to eq("Couldn't find Vendor with 'id'=#{non_existent_vendor_id}")
    end

    it 'returns a 500 error when something goes wrong on the server' do
      vendor = create(:vendor)

      update_params = attributes_for(:vendor).merge(
        name: 'Updated Name',
        description: 'Updated Description',
        contact_name: 'Updated Contact',
        contact_phone: '123-456-7890',
        credit_accepted: false
      )

      allow(Vendor).to receive(:find).and_raise(StandardError.new('Something went wrong'))

      patch "/api/v0/vendors/#{vendor.id}", params: { vendor: update_params }

      expect(response).to have_http_status(500)
    end
  end

  # Delete a Vendor
  describe 'DELETE /api/v0/vendors/:id' do
    # Happy Path
    it 'deletes an existing vendor and returns a 204' do
      vendor = create(:vendor)

      delete "/api/v0/vendors/#{vendor.id}"

      expect(response).to have_http_status(204)

      expect { Vendor.find(vendor.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    # Sad Path
    it 'returns a 404 error if vendor does not exist' do
      delete '/api/v0/vendors/123123123123'

      expect(response).to have_http_status(404)

      expect(JSON.parse(response.body)['errors'].first['detail']).to eq("Couldn't find Vendor with 'id'=123123123123")
    end

    it 'returns a 500 error when something goes wrong on the server' do
      vendor = create(:vendor)

      allow(Vendor).to receive(:find).and_raise(StandardError.new('Something went wrong'))

      delete "/api/v0/vendors/#{vendor.id}"

      expect(response).to have_http_status(500)
    end
  end
end
