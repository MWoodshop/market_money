class Api::V0::VendorsController < ApplicationController
  # 4. Get One Vendor
  def show
    vendor = Vendor.find(params[:id])
    render json: {
      data: {
        id: vendor.id.to_s,
        type: 'vendor',
        attributes: vendor.attributes
      }
    }, status: 200
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end
end
