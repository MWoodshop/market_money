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
    begin
      market = Market.find(params[:market_id])
      vendor = Vendor.find(params[:vendor_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: [{ detail: e.message }] }, status: :not_found
      return
    end

    # Check if the market-vendor relationship already exists
    if MarketVendor.exists?(market_id: market.id, vendor_id: vendor.id)
      render json: { errors: ['This vendor is already associated with this market'] }, status: :unprocessable_entity
      return
    end

    market_vendor = MarketVendor.new(market:, vendor:)

    if market_vendor.save
      render json: { message: 'Successfully added vendor to market' }, status: :created
    else
      render json: { errors: market_vendor.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
  end

  # 9. Delete a Market Vendor
  def destroy
    params_for_removal = params.require(:market_vendor).permit(:market_id, :vendor_id)
    market_id = params_for_removal[:market_id]
    vendor_id = params_for_removal[:vendor_id]

    market_vendor = MarketVendor.find_by(market_id:, vendor_id:)

    if market_vendor
      market_vendor.destroy
      head :no_content # This sends a 204 status
    else
      render json: { errors: [{ detail: "No MarketVendor with market_id=#{market_id} AND vendor_id=#{vendor_id} exists" }] },
             status: 404
    end
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
