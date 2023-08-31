class TomtomService
  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def fetch_atms
    conn = Faraday.new(url: 'https://api.tomtom.com')
    response = conn.get do |req|
      req.url '/search/2/categorySearch/ATM.json'
      req.params['key'] = ENV['TOMTOM_API_KEY']
      req.params['lat'] = @lat
      req.params['lon'] = @lon
      req.params['radius'] = 5000
    end
    parse_response(response.body)
  end

  private

  def parse_response(body)
    json_response = JSON.parse(body)
    sorted_atms = json_response['results'].sort_by { |atm| atm['dist'] }
    format_atms(sorted_atms)
  end

  def format_atms(sorted_atms)
    sorted_atms.map do |atm|
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
  end
end
