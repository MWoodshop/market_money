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
end
