module MarketVendorsControllerHelper
  private

  def set_market
    @market = Market.find(params[:market_id])
  rescue ActiveRecord::RecordNotFound => e
    # Returning 404 here
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
    @market_vendor = MarketVendor.find_by(market_id: @market_id, vendor_id: @vendor_id)

    if @market_vendor.nil?
      render json: { errors: ["No MarketVendor with market_id=#{@market_id} AND vendor_id=#{@vendor_id} exists"] },
             status: :not_found
    end
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: :internal_server_error
  end
end
