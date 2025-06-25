class ApartmentsController < ApplicationController

  def index

    summary_rows = ApartmentUnitVisit
    .joins(:apartment)
    .select(
      "apartments.id AS apartment_id",
      "apartments.name AS apartment_name",
      "COUNT(*) AS visit_count",
      "MAX(apartment_unit_visits.visited_at) AS most_recent_visit"
    )
    .group("apartments.id, apartments.name")

    all_unique_unit_visits = ApartmentUnitVisit
    .select(:apartment_id, :building_name, :unit_number)
    .distinct
    
    unit_names_by_apartment = all_unique_unit_visits.map do |visit|
      building = visit.building_name.presence
      unit = visit.unit_number.presence

      unit_name = if building && unit
                    "#{building} - #{unit}"
                  elsif building
                    building
                  else
                    unit || "" # default to empty string if both are nil
                  end
    
      [visit.apartment_id, unit_name]
    end
    .group_by(&:first) # groups by apartment_id, returns a hash by apt id
    .transform_values do |pairs|
      pairs.map(&:last).uniq.sort_by(&:downcase)
    end
     
    @apartments = summary_rows.map do |row|
      {
        apartment_name: row.apartment_name,
        visit_count: row.visit_count.to_i,
        visited_units: unit_names_by_apartment[row.apartment_id] || [], 
        most_recent_visit: row.most_recent_visit&.to_time
      }
    end

    @apartments.sort_by! { |row| row[:most_recent_visit] || Time.at(0) }.reverse!

  end
end
