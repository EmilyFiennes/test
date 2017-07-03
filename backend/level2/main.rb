require "json"
require_relative "rental"
require_relative "car"
require 'pry'

puts "Fetching raw data....."

#fetch JSON and parse
filepath = "data.json"
raw_data = File.read(filepath)
data = JSON.parse(raw_data)

#build array of car objects from parsed JSON
cars = data["cars"].map {|car_data| Car.new(car_data)}

#build array of rental objects from parsed JSON, including car object associated with rental
rentals = data["rentals"].map {|rental_data| Rental.new(
  rental_data['id'],
  cars.select { |c| c.id == rental_data['car_id'] }.first,
  Date.parse(rental_data['start_date']),
  Date.parse(rental_data['end_date']),
  rental_data['distance']
  )}

#calculate full prices of rentals, now including duration saving
output = {rentals: []}
rentals.each do |rental|
  output[:rentals] << { 'id' => rental.id, 'price' => rental.full_price }
end

puts "printing full prices of rentals with built in duration saving"
puts "-------------------"

#print output
print output

puts "printing complete"
puts

#Generate prettified JSON file from output
puts "generating JSON file"
puts "--------------------"
# Generate prettified JSON file from output
File.open('output_generated.json', 'wb') do |file|
  file.write(JSON.pretty_generate(output))
end
puts "--------------------"
puts "JSON file generated"
