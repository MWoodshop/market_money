class Api::V0::MarketsController < ApplicationController
  def index
    markets = Market.all
    render json: markets.map { |market| market.as_json.merge({ vendor_count: market.vendor_count }) }
  end
end
