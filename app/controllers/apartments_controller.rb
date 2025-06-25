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

    all_unit_visits = ApartmentUnitVisit
    .select(:apartment_id, :building_name, :unit_number)
    .distinct
    
    visits_by_apartment = all_unit_visits.group_by { |visit| visit.apartment_id }
     
    # O(n*m)
    @apartments = summary_rows.map do |row|
    raw_units = visits_by_apartment[row.apartment_id] || []

    visited_units = raw_units.map do |v|
      building_str = v.building_name.presence || ""
      unit_str = v.unit_number.presence || ""
      "#{building_str} - #{unit_str}"

    end.sort_by { |v| v.downcase }

    {
      apartment_name: row.apartment_name,
      visit_count: row.visit_count.to_i,
      visited_units: visited_units,
      most_recent_visit: row.most_recent_visit&.to_time
    }
  end

  @apartments.sort_by! { |row| row[:most_recent_visit] || Time.at(0) }.reverse!


  end
end
