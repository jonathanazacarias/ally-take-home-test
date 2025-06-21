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

  @apartments = summary_rows.map do |row|

    visited_units = ApartmentUnitVisit
      .where(apartment_id: row.apartment_id)
      .distinct 
      .pluck(:building_name, :unit_number) 
      .map do |building, unit|
        building_str = building.presence || ""
        unit_str = unit.presence || ""
        "#{building_str} - #{unit_str}"
      end
      .sort_by { |name| name.downcase }
    {
      apartment_name: row.apartment_name,
      visit_count: row.visit_count,
      visited_units: visited_units,
      most_recent_visit: row.most_recent_visit.present? ? Time.parse(row.most_recent_visit.to_s) : nil
    }
  end

    @apartments.sort_by! { |row| row[:most_recent_visit] || Time.at(0) }.reverse!

  end
end
