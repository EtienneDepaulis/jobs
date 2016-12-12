require "rspec"

require "./backend/level3/main.rb"

RSpec.describe Rental, type: :model do

  let(:car)       { Car.new(id: 1, price_per_day: 2000, price_per_km: 10) }
  let(:rental)    { Rental.new(id: 1, car: car, start_date: "2015-07-3", end_date: "2015-07-14", distance: 1000) }

  context ":set_price" do
    it 'sets the correct price' do
      rental.set_price

      comission = rental.commission

      expect(comission.insurance_fee).to eq(4170)
      expect(comission.assistance_fee).to eq(1200)
      expect(comission.drivy_fee).to eq(2970)
    end
  end
end

RSpec.describe CalculateRentalPrices, type: :model do

  let(:data)          { JSON.parse(File.read('./backend/level3/data.json')) }
  let(:output)        { JSON.parse(File.read('./backend/level3/output.json')) }


  it 'sets all prices' do
    calculator = CalculateRentalPrices.new(data)

    expect(calculator.call).to eq(output)
  end

end
