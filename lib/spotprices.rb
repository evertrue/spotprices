require "spotprices/version"

module EverTools
  class SpotPrices
    require 'fog'

    def connection
      @connection ||= Fog::Compute::AWS.new
    end

    def prices
      p = connection.describe_spot_price_history.body['spotPriceHistorySet']
      p = p.select do |s|
        s['productDescription'] == 'Linux/UNIX (Amazon VPC)' &&
          s['availabilityZone'] == 'us-east-1c'
      end
      output = []
      p.map { |s| s['instanceType'] }.uniq.each do |s|
        output << p.select { |spot| spot['instanceType'] == s }.first
      end
      output
    end

    def display_header
      printf("%-11s %8s\n", 'Flavor', 'Price')
      printf("%s\n", '-' * 20)
    end

    def run
      display_header
      prices.sort_by { |s| s['instanceType'] }.each do |s|
        printf("%-11s %8s\n", s['instanceType'], s['spotPrice'])
      end
    end
  end
end
