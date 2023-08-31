class Api::V0::MarketVendorsController < ApplicationController
  before_action :set_market, only: %i[index create]
  before_action :set_vendor, only: [:create]
  before_action :set_market_vendor, only: [:destroy]

  # 3. Get All Vendors for a Market
  def index
    render json: MarketVendorSerializer.new(@market.vendors).serializable_hash.to_json, status: :ok
  end

  # 8. Create a Market Vendor
  def create
    if MarketVendor.exists?(market: @market, vendor: @vendor)
      render json: { errors: ['This vendor is already associated with this market'] }, status: :unprocessable_entity
    else
      MarketVendor.create!(market: @market, vendor: @vendor)
      render json: { message: 'Successfully added vendor to market' }, status: :created
    end
  end

  # 9. Delete a Market Vendor
  def destroy
    @market_vendor.destroy!
    head :no_content
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
  end

  private

  def set_market
    @market = Market.find(params[:market_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: :not_found
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
  end

  def set_vendor
    @vendor = Vendor.find(params[:vendor_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: :not_found
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
  end

  def set_market_vendor
    params_for_removal = params.require(:market_vendor).permit(:market_id, :vendor_id)
    @market_id = params_for_removal[:market_id]
    @vendor_id = params_for_removal[:vendor_id]

    begin
      @market_vendor = MarketVendor.find_by!(market_id: @market_id, vendor_id: @vendor_id)
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: [{ detail: "No MarketVendor with market_id=#{@market_id} AND vendor_id=#{@vendor_id} exists" }] },
             status: :not_found
    rescue StandardError => e
      render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
    end
  end
end
