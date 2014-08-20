require "spotprices/version"

module Spotprices
  require 'fog'

  def connection
    @connection ||= Fog::Compute::AWS.new
  end

  def prices
    p = connection.describe_spot_price_history.body['spotPriceHistorySet']
    p.select do |s|
      s['productDescription'] == 'Linux/UNIX (Amazon VPC)' &&
        s['availabilityZone'] == 'us-east-1b'
    end
  end

  def display_header
    printf('%-11s %8s', 'flavor', 'price')
  end

  def run
    display_header
    prices.each do |s|
      printf('%s %s', s['instanceType'], s['spotPrice'])
    end
  end
end
