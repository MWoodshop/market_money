class Api::V0::MarketVendorsController < ApplicationController
  def index
    market = Market.find(params[:market_id])
    vendors = market.vendors
    render json: {
      data: vendors.map do |vendor|
        {
          id: vendor.id.to_s,
          type: 'vendors',
          attributes: vendor.attributes.except('id', 'created_at', 'updated_at')
        }
      end
    }, status: 200
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
