require "spotprices/version"

module EverTools
  class SpotPrices
    require 'fog'

    def connection
      @connection ||= Fog::Compute::AWS.new
    end

    def prices
      p = connection.describe_spot_price_history.body['spotPriceHistorySet']
      output = []
      p.map { |s| s['productDescription'] }.uniq.each do |s_d|
        p.map { |s| s['instanceType'] }.uniq.each do |s_i|
          output << p.select { |spot|
            spot['instanceType'] == s_i &&
              spot['productDescription'] == s_d
          }.first
        end
      end
      output.delete(nil)
      output
    end

    def display_header
      output_header = format(
        '%-11s %-25s %8s',
        'Flavor',
        'Description',
        'Price'
      )
      puts output_header
      puts '-' * output_header.length
    end

    def list
      display_header
      prices.sort { |a, b|
        if a['productDescription'] == b['productDescription']
          a['instanceType'] <=> b['instanceType']
        else
          a['productDescription'] <=> b['productDescription']
        end
      }.each do |s|
        printf(
          "%-11s %-25s %8s\n",
          s['instanceType'],
          s['productDescription'],
          s['spotPrice']
        )
      end
    end

    def run
      list if ARGV.empty?
    end
  end
end
