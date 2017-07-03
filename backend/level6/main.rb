require "json"
require_relative "rental"
require_relative "car"
require_relative "action"
require_relative "rental_modification"
require 'pry'

puts "Fetching raw data....."

# fetch JSON and parse
filepath = "data.json"
raw_data = File.read(filepath)
data = JSON.parse(raw_data)

# build array of car objects from parsed JSON
cars = data["cars"].map {|car_data| Car.new(car_data)}

# build array of rentals objects from parsed JSON, including car object associated with rental
rentals = data["rentals"].map do |rental_data| Rental.new(
  rental_data['id'],
  cars.select { |c| c.id == rental_data['car_id'] }.first,
  Date.parse(rental_data['start_date']),
  Date.parse(rental_data['end_date']),
  rental_data['distance'],
  rental_data['deductible_reduction']
  )
end

# calculate rental breakdown for various actors
rental_output = {rentals: []}

rentals.each do |rental|
  rental_output[:rentals] << { 'id' => rental.id, 'actions' => rental.compute_actions }
end

# print output
print rental_output

#parse json to build array of rental_modification objects
rental_modifications = data["rental_modifications"].map do |rental_modification_data| RentalModification.new(
  rental_modification_data['id'],
  rentals.select { |r| r.id == rental_modification_data['rental_id']}.first,
  rental_modification_data['start_date'],
  rental_modification_data['end_date'],
  rental_modification_data['distance']
  )
end

# calculate new rental breakdown for various actors, and difference to be credited/debited
rental_modification_output = {rental_modifications: []}

rental_modifications.each do |rental_modification|
  rental_modification_output[:rental_modifications] << {
    'id' => rental_modification.id,
    'rental_id' => rental_modification.rental.id,
    'actions' => rental_modification.serialize_actions }
end

puts "printing full prices of rentals with breakdown for different actors"
puts "-------------------"

#print rental modification output
print rental_modification_output

puts "printing complete"
puts "-------------------"

#Generate prettified JSON file from output
puts "generating JSON file"
puts "--------------------"
# Generate prettified JSON file from output
File.open('output_generated.json', 'wb') do |file|
  file.write(JSON.pretty_generate(rental_modification_output))
end
puts "--------------------"
puts "JSON file generated"
