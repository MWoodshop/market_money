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

  def create
    vendor = Vendor.new(vendor_params)
    if vendor.save
      render json: VendorSerializer.new(vendor).serializable_hash.to_json, status: :created
    else
      render json: { errors: vendor.errors.full_messages }, status: :bad_request
    end
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :description, :contact_name, :contact_phone, :credit_accepted)
  end
end
