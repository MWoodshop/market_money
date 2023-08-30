class MarketVendorSerializer
  include JSONAPI::Serializer
  set_type :vendor
  attributes :name, :description, :contact_name, :contact_phone, :credit_accepted
end
