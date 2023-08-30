class Api::V0::VendorsController < ApplicationController
  # 4. Get One Vendor
  def show
    vendor = Vendor.find(params[:id])
    render json: VendorSerializer.new(vendor).serializable_hash.to_json, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: 404
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end

  # 5. Create a Vendor
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

  # 6. Update a Vendor
  def update
    # Find the existing vendor
    vendor = Vendor.find(params[:id])

    # Update the vendor with the new attributes
    if vendor.update(vendor_params)
      render json: VendorSerializer.new(vendor).serializable_hash.to_json, status: :ok
    else
      render json: { errors: vendor.errors.full_messages }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: :not_found
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500
  end

  # 7. Delete a Vendor
  def destroy
    vendor = Vendor.find(params[:id])
    vendor.destroy

    # Send back a 204 No Content response
    render json: {}, status: :no_content
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: [{ detail: e.message }] }, status: :not_found
  rescue StandardError => e
    render json: { errors: [{ detail: e.message }] }, status: 500

  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :description, :contact_name, :contact_phone, :credit_accepted)
  end
end
