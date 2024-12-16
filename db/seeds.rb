# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

50.times do |i|
  Apartment.create!(name: "Apartment #{i}")
end

building_names = %w[North South East West Garage]
unit_numbers = ['100', '101', '102', '103', 'Pool House', 'Exercise Room']

Apartment.all.each do |apartment|
  3.times do
    building_names.each do |building_name|
      unit_numbers.each do |unit_number|
        next if rand < 0.5

        if building_name == 'Garage'
          ApartmentUnitVisit.create!(
            apartment: apartment,
            building_name: building_name,
            visited_at: rand(1.years).seconds.ago
          )
        elsif ['Pool House', 'Exercise Room'].include?(unit_number)
          ApartmentUnitVisit.create!(
            apartment: apartment,
            unit_number: unit_number,
            visited_at: rand(1.years).seconds.ago
          )
        else
          ApartmentUnitVisit.create!(
            apartment: apartment,
            building_name: building_name,
            unit_number: unit_number,
            visited_at: rand(1.years).seconds.ago
          )
        end
      end
    end
  end
end
