class Api::V0::MarketsController < ApplicationController
  # 1. Get All Markets
  def index
    markets = Market.all
    render json: MarketSerializer.new(markets).serializable_hash.to_json, status: :ok
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end

  # 2. Get One Market
  def show
    market = Market.find(params[:id])
    render json: MarketSerializer.new(market).serializable_hash.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
