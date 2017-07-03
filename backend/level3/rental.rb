# This "require" line loads the contents of the 'date' file from the standard
# Ruby library, giving you access to the Date class.
require 'date'

class Rental
  attr_reader :id, :car, :start_date, :end_date, :distance

  REDUCTIONS = [
    {percentage: 1, days: 0..1 },
    {percentage: 0.9, days: 2..4},
    {percentage: 0.7, days: 5..10},
    {percentage: 0.5 , days: 11..Float::INFINITY}
  ]

  # values for commission structure calculation
  RATE_FOR_COMMISSION_ON_RENTAL_PRICE = 0.3
  RATE_FOR_INSURANCE_ON_COMMISSION = 0.5
  RATE_FOR_ROADSIDE_ASSISTANCE_ON_COMMISSION = 100 #(price in cents)

  #start_date and end_date will need to be parsed
  def initialize(id, car, start_date, end_date, distance)
    @id = id
    @car = car
    @start_date = start_date
    @end_date = end_date
    @distance = distance
  end

  def car
    Car.new(
      'id' => @car.id,
      'price_per_day' => @car.price_per_day,
      'price_per_km' => @car.price_per_km
      )
  end

  def days
    (self.end_date - self.start_date).to_i + 1
  end

  def price_time_component
    (self.days) * self.car.price_per_day
  end

  def price_for_given_day(day)
    reduction = REDUCTIONS.find { |r| r[:days].include?(day) }
    self.car.price_per_day * reduction[:percentage]
  end

  def price_time_component_with_duration_saving
    (1..days).reduce(0) do |sum, day|
      sum + price_for_given_day(day).to_i
    end
  end

  def price_distance_component
    self.distance * self.car.price_per_km
  end

  def full_price
    self.price_time_component_with_duration_saving + self.price_distance_component
  end

  # Commission share is 30%
  def calculate_full_commission_share
    self.full_price * RATE_FOR_COMMISSION_ON_RENTAL_PRICE
  end

  # 50% of commission share goes to insurance
  def calculate_insurance_fee_on_commission
    self.calculate_full_commission_share * RATE_FOR_INSURANCE_ON_COMMISSION
  end

  # Roadside assistance is calculated in 100 cents and rounded to nearest euro
  #(1€/day for the duration of the rental)
  def calculate_roadside_assistance_fee_on_commission
    (self.days * RATE_FOR_ROADSIDE_ASSISTANCE_ON_COMMISSION).round
  end

  # the rest goes to Drivy
  def calculate_drivy_share_on_commmission
    self.calculate_full_commission_share - self.calculate_insurance_fee_on_commission - self.calculate_roadside_assistance_fee_on_commission
  end

  def commission_structure
    commission = {
      "insurance_fee" => self.calculate_insurance_fee_on_commission.to_i,
      "assistance_fee" => self.calculate_roadside_assistance_fee_on_commission.to_i,
      "drivy_fee" => self.calculate_drivy_share_on_commmission.to_i
    }
  end
end
