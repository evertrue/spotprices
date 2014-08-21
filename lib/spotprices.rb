require "spotprices/version"

module EverTools
  class FlavorPrice
    attr_accessor :prices

    def latest
      prices[prices.keys.sort.last]
    end

    def earliest
      prices[prices.keys.sort.first]
    end

    def highest
      prices.values.sort.last
    end

    def lowest
      prices.values.sort.first
    end

    def mean
      a = prices.values
      (a.reduce(0.0, :+) / a.size).round(4)
    end
  end

  class SpotPrices
    require 'fog'
    require 'colorize'

    def connection
      @connection ||= Fog::Compute::AWS.new
    end

    def keyout(key, value, indent = 0)
      print("#{' ' * indent}#{key.bold.black}: #{value}\n")
    end

    def prices
      @prices ||= connection.describe_spot_price_history.body['spotPriceHistorySet']
    end

    def filtered_prices
      output = []
      prices.map { |s| s['productDescription'] }.uniq.each do |s_d|
        prices.map { |s| s['instanceType'] }.uniq.each do |s_i|
          output << p.select { |spot|
            spot['instanceType'] == s_i &&
              spot['productDescription'] == s_d
          }.first
        end
      end
      output.delete(nil)
      output
    end

    def full_list_header
      output_header = format(
        '%-11s %-25s %8s',
        'Flavor',
        'Description',
        'Price'
      )
      puts output_header
      puts '-' * output_header.length
    end

    def full_list
      full_list_header
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

    def flavor_prices
      prices.select { |spot| spot['instanceType'] == @flavor }
    end

    def products
      if @flavor
        flavor_prices.map { |s| s['productDescription'] }.uniq.sort
      else
        prices.map { |s| s['productDescription'] }.uniq.sort
      end
    end

    def zones
      if @flavor
        flavor_prices.map { |s| s['availabilityZone'] }.uniq.sort
      else
        prices.map { |s| s['availabilityZone'] }.uniq.sort
      end
    end

    def prices_by_time(flavor, zone, product)
      output = {}
      (@flavor? flavor_prices : prices).select do |p|
        p['instanceType'] == flavor &&
          p['availabilityZone'] == zone &&
          p['productDescription'] == product
      end.each do |p|
        output[p['timestamp']] = p['spotPrice']
      end
      output
    end

    def one_type
      keyout 'Instance Type', @flavor
      products.each do |product|
        keyout 'Product', product, 2
        zones.each do |zone|
          fp = FlavorPrice.new
          fp.prices = prices_by_time(@flavor, zone, product)
          unless fp.prices.empty?
            keyout(
              zone,
              "(H#{fp.highest}/L#{fp.lowest}/M#{fp.mean}) " \
                "#{Hash[fp.prices.sort.reverse].values.join(', ')}",
              4
            )
          end
        end
      end
    end

    def initialize(args)
      @args = args
      @flavor = args[0] unless args.empty?
    end

    def run
      if @args.empty?
        full_list
      else
        one_type
      end
    end
  end
end
