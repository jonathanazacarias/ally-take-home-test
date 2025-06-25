
class TestingController < ApplicationController
  def index
    summary_rows = ApartmentUnitVisit
    .joins(:apartment)
    .select(
      "apartments.id AS apartment_id",
      "apartments.name AS apartment_name",
      "apartment_unit_visits.building_name AS building_name",
      "apartment_unit_visits.unit_number AS unit_number"
    )
    .order("apartments.id")

    # apartment_unit_visit_rows = ApartmentUnitVisit
    # .select(
    #   "apartment_unit_visits.building_name AS building_name",
    #   "apartment_unit_visits.unit_number AS unit_number",
    #   ""
    # )

    # PostgreSQL version with the ARRAY_AGG function
    # summary_rows = ApartmentUnitVisit
    #   .joins(:apartment)
    #   .select(
    #     "apartments.id AS apartment_id",
    #     "apartments.name AS apartment_name",
    #     "COUNT(*) AS visit_count",
    #     "MAX(apartment_unit_visits.visited_at) AS most_recent_visit",
    #     "ARRAY_AGG(DISTINCT apartment_unit_visits.building_name || ' - ' || apartment_unit_visits.unit_number) AS visited_units"
    #   )
    #   .group("apartments.id, apartments.name")

    # @apartments = summary_rows.map do |row|
    #   {
    #     apartment_name: row.apartment_name,
    #     visit_count: row.visit_count.to_i,
    #     visited_units: (row.visited_units || []).sort_by { |v| v.downcase },
    #     most_recent_visit: row.most_recent_visit&.to_time
    #   }

    @apartments = summary_rows.map do |row|
      {
        apartment_id: row.apartment_id,
        apartment_name: row.apartment_name,
        building_name: row.building_name,
        unit_number: row.unit_number
      }
    end

    @apartments = @apartments.paginate page: params[:page], per_page: 20

  end
end