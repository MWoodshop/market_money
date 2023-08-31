class MarketSearchService
  def initialize(params)
    @state = params[:state]
    @city = params[:city]
    @name = params[:name]
  end

  def call
    validate_parameters

    query = build_query
    serialize_results(query)
  end

  private

  def validate_parameters
    return unless @city.present? && @state.blank?

    raise ArgumentError,
          'Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint.'
  end

  def build_query
    query = Market.all

    query = query.where('state ILIKE ?', "%#{@state}%") if @state.present?
    query = query.where('city ILIKE ?', "%#{@city}%") if @city.present?
    query = query.where('name ILIKE ?', "%#{@name}%") if @name.present?

    query
  end

  def serialize_results(query)
    query.map do |market|
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
  end
end
