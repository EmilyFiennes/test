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
end
