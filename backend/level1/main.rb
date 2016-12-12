require "json"
require "virtus"
require "awesome_print"

class CalculateRentalPrices

  def initialize(data)
    @data = data
    @rentals = []
  end

  attr_reader :data, :rentals

  def call
    extract_rentals

    rentals.each(&:set_price)

    export_rentals
  end

  private

    def extract_rentals
      cars = data["cars"].map do |car_data|
        Car.new(car_data)
      end

      @rentals = data["rentals"].map do |rental_data|
        rental = Rental.new(rental_data)
        matching_cars = cars.select {|car| car.id == rental_data["car_id"]}
        rental.car = matching_cars.first

        rental
      end

    end

    def export_rentals
      { "rentals" => rentals.map(&:to_json) }
    end

end


class Car

  include Virtus.model

  attribute :id, Integer
  attribute :price_per_day, Integer
  attribute :price_per_km, Integer

end

class Rental

  include Virtus.model

  attribute :id, Integer
  attribute :car, Car
  attribute :start_date, Date
  attribute :end_date, Date
  attribute :distance, Integer
  attribute :price, Integer, default: 0

  def set_price
    raise "No car provided" if car.nil?

    duration_price = duration_in_days * car.price_per_day
    distance_price = distance * car.price_per_km

    @price = duration_price + distance_price
  end

  def to_json
    {"id" => id, "price" => price}
  end

  private

    def duration_in_days
      (end_date - start_date).to_i + 1
    end
end
