require 'date'

class Rental
  attr_reader :id, :car, :start_date, :end_date, :distance

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
    #1 day to include the first day of rental
    (self.end_date - self.start_date).to_i + 1
  end

  def price_time_component
    (self.days) * self.car.price_per_day
  end

  def price_distance_component
    self.distance * self.car.price_per_km
  end

  def full_price
    self.price_time_component + self.price_distance_component
  end

end
