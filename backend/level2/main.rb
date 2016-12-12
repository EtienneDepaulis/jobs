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


class Base

  include Virtus.model

end

class Car < Base

  attribute :id, Integer
  attribute :price_per_day, Integer
  attribute :price_per_km, Integer

end

class Discount < Base

  attribute :starting_day, Integer
  attribute :percentage, Float

  def apply(duration)
    applied_duration = [duration - starting_day + 1, 0].max.to_f
    remaining_days = duration - applied_duration

    discounted_days_to_add = applied_duration * percentage / 100

    [remaining_days, discounted_days_to_add]
  end

end

class Rental < Base

  DISCOUNTS = [
    Discount.new(starting_day: 11, percentage: 50),
    Discount.new(starting_day: 5, percentage: 70),
    Discount.new(starting_day: 2, percentage: 90),
    Discount.new(starting_day: 1, percentage: 100)
  ]

  attribute :id, Integer
  attribute :car, Car
  attribute :start_date, Date
  attribute :end_date, Date
  attribute :distance, Integer
  attribute :price, Integer, default: 0

  def set_price
    raise "No car provided" if car.nil?

    duration_price = (duration_in_days_discounted * car.price_per_day).to_i
    distance_price = distance * car.price_per_km

    @price = duration_price + distance_price
  end

  def to_json
    {"id" => id, "price" => price}
  end

  private

    def duration_in_days_discounted

      remaining_days = duration_in_days

      discounted_days = DISCOUNTS.map do |discount|
        remaining_days, discounted_days_to_add = discount.apply(remaining_days)

        discounted_days_to_add
      end

      discounted_days.inject(:+)
    end

    def duration_in_days
      (end_date - start_date).to_i + 1
    end
end

