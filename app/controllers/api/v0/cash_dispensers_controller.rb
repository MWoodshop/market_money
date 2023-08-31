class Api::V0::CashDispensersController < ApplicationController
  require 'faraday'

  # 10. Get Dispensers Near a Market
  def nearest
    market = Market.find(params[:market_id])
    formatted_atms = TomtomService.new(market.lat, market.lon).fetch_atms
    render json: { data: formatted_atms }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: "Couldn't find Market with 'id'=#{params[:market_id]}" }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
