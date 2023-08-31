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

  # 10. Search Markets by state, city, and/or name
  def search
    state = params[:state]
    city = params[:city]
    name = params[:name]

    # Validate parameters
    if city.present? && state.blank?
      # "city" alone or "city" with "name" is invalid without "state"
      render json: { errors: [{ detail: 'Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint.' }] },
             status: :unprocessable_entity
      return
    end

    query = Market.all

    query = query.where('state ILIKE ?', "%#{state}%") if state.present?
    query = query.where('city ILIKE ?', "%#{city}%") if city.present?
    query = query.where('name ILIKE ?', "%#{name}%") if name.present?

    results = query.map do |market|
      {
        id: market.id,
        type: 'market',
        attributes: {
          name: market.name,
          street: market.street,
          city: market.city,
          county: market.county,
          state: market.state,
          zip: market.zip,
          lat: market.lat,
          lon: market.lon,
          vendor_count: market.vendors.count
        }
      }
    end

    render json: { data: results }, status: :ok
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
