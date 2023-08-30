class VendorSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :description, :contact_name, :contact_phone, :credit_accepted
end
