class MarketVendorService
  def self.create_market_vendor(market, vendor)
    if MarketVendor.exists?(market:, vendor:)
      { errors: [{ detail: 'This vendor is already associated with this market' }], status: :unprocessable_entity }
    else
      MarketVendor.create!(market:, vendor:)
      { message: 'Successfully added vendor to market', status: :created }
    end
  end

  def self.destroy_market_vendor(market_vendor)
    return { status: :not_found } if market_vendor.nil?

    market_vendor.destroy!
    { status: :no_content }
  rescue StandardError => e
    { errors: [{ detail: e.message }], status: :internal_server_error }
  end
end
