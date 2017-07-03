require 'date'
class RentalModification < Rental
  attr_reader :id, :rental, :start_date, :end_date, :distance

  #start_date, end_date and distance initialized at nil incase they are not modified
  def initialize(id, rental, start_date = nil, end_date = nil, distance = nil)
    @id = id
    @rental = rental
    @start_date = start_date ? Date.parse(start_date) : @rental.start_date
    @end_date = end_date ? Date.parse(end_date) : @rental.end_date
    @distance = distance ||  @rental.distance
    @car = rental.car
    @deductible_reduction = rental.deductible_reduction
  end

  def compute_actions
    previous_rental_actions = @rental.compute_actions
    modified_rental_actions = super

    actions = []
    modified_rental_actions.each_with_index do |modified_rental_action, index|
      actions << Action.new(
        modified_rental_action.who,
        modified_rental_action.amount - previous_rental_actions[index].amount
      )
    end
    actions
  end
end

