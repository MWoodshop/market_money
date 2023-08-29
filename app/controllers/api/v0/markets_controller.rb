class Api::V0::MarketsController < ApplicationController
  def index
    markets = Market.all
    render json: { data: markets.map do |market|
      {
        id: market.id.to_s,
        type: 'market',
        attributes: market.attributes.merge({ vendor_count: market.vendor_count })
      }
    end }
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end

  def show
    market = Market.find(params[:id])
    render json: {
      data: {
        id: market.id,
        type: 'market',
        attributes: market.attributes.merge({ vendor_count: market.vendor_count })
      }
    }, status: 200
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
