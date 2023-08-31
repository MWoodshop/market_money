class MarketVendor < ApplicationRecord
  belongs_to :market
  belongs_to :vendor

  validates :market_id, presence: true
  validates :market_id,
            uniqueness: { scope: :vendor_id, message: 'association between market and vendor already exists' }
end
