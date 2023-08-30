class Api::V0::MarketVendorsController < ApplicationController
  # 3. Get All Vendors for a Market
  def index
    market = Market.find(params[:market_id])
    vendors = market.vendors
    render json: MarketVendorSerializer.new(vendors).serializable_hash.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end

  # 8. Create a Market Vendor
  def create
    market = Market.find(params[:market_id])
    vendor = Vendor.find(params[:vendor_id])

    market_vendor = MarketVendor.new(market:, vendor:)

    if market_vendor.save
      render json: { message: 'Successfully added vendor to market' }, status: :created
    else
      render json: { errors: market_vendor.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
