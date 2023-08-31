class Api::V0::MarketVendorsController < ApplicationController
  include MarketVendorsControllerHelper

  before_action :set_market, only: %i[index create]
  before_action :set_vendor, only: [:create]
  before_action :set_market_vendor, only: [:destroy]

  # 3. Get All Vendors for a Market
  def index
    render_jsonapi(@market.vendors, MarketVendorSerializer, status: :ok)
  end

  # 8. Create a Market Vendor
  def create
    result = MarketVendorService.create_market_vendor(@market, @vendor)
    if result[:status] == :unprocessable_entity
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    else
      render json: { message: result[:message] }, status: result[:status] || :internal_server_error
    end
  end

  # 9. Delete a Market Vendor
  def destroy
    @market_vendor.destroy!
    head :no_content
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
  end
end
