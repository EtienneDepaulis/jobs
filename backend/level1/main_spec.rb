require "rspec"

require "./backend/level1/main.rb"

RSpec.describe Rental, type: :model do

  let(:car)       { Car.new(id: 1, price_per_day: 3000, price_per_km: 15) }
  let(:rental)    { Rental.new(id: 1, car: car, start_date: "2017-12-8", end_date: "2017-12-10", distance: 150) }

  context ":set_price" do
    it 'sets the correct price' do
      rental.set_price

      expect(rental.price).to eq(11250)
    end
  end
end

RSpec.describe CalculateRentalPrices, type: :model do

  let(:data)          { JSON.parse(File.read('./backend/level1/data.json')) }
  let(:output)        { JSON.parse(File.read('./backend/level1/output.json')) }


  it 'sets all prices' do
    calculator = CalculateRentalPrices.new(data)

    expect(calculator.call).to eq(output)
  end

end
