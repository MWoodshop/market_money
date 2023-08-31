class Api::V0::CashDispensersController < ApplicationController
  require 'faraday'

  # 10. Get Dispensers Near a Market
  def nearest
    market = Market.find(params[:market_id])
    lat = market.lat
    lon = market.lon

    # Initialize Faraday connection
    conn = Faraday.new(url: 'https://api.tomtom.com')

    # Make API call to TomTom
    response = conn.get do |req|
      req.url '/search/2/categorySearch/ATM.json'
      req.params['key'] = ENV['TOMTOM_API_KEY']
      req.params['lat'] = lat
      req.params['lon'] = lon
      req.params['radius'] = 5000 # Radius in meters, you can adjust this
    end

    # Parse the response
    json_response = JSON.parse(response.body)

    # Sort ATMs them by distance
    sorted_atms = json_response['results'].sort_by { |atm| atm['dist'] }

    # Format sorted_atms to match response format
    formatted_atms = sorted_atms.map do |atm|
      {
        id: nil,
        type: 'atm',
        attributes: {
          name: atm['poi']['name'],
          address: atm['address']['freeformAddress'],
          lat: atm['position']['lat'],
          lon: atm['position']['lon'],
          distance: atm['dist']
        }
      }
    end

    render json: { data: formatted_atms }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: "Couldn't find Market with 'id'=#{params[:market_id]}" }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
