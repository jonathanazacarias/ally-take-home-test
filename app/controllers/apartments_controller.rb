class ApartmentsController < ApplicationController

  #create a method for the index action
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

    #create a var with the data for the table
    @apartments = summary_rows.map do |row|
      visited_units = ApartmentUnitVisit
      .where(apartment_id: row.apartment_id)
      .where.not(unit_number: nil, building_name: nil)
      .distinct
      .pluck(:building_name, :unit_number)
      .map { |building, unit| "#{building} - #{unit}" }
      .sort_by { |name| name.downcase }  # or use a custom sort block if needed

      {
        apartment_name: row.apartment_name,
        visit_count: row.visit_count,
        most_recent_visit: row.most_recent_visit.present? ? Time.parse(row.most_recent_visit.to_s) : nil,
        visited_units: visited_units
      }
    end

    @apartments.sort_by! { |row| row[:most_recent_visit] || Time.at(0) }.reverse!
  end
end
