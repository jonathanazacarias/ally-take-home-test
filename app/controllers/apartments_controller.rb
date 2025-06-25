# ApartmentsController
# ---------------------
# The index action loads summarized apartment visit data:
# - Fetches each apartment's total number of visits and most recent visit timestamp
# - Gathers distinct unit names (building + unit number) visited per apartment
# - Returns a sorted list of apartments by most recent visit, for reporting/display
# All queries are optimized to reduce N+1 issues and minimize database round-trips for SQLite3.

class ApartmentsController < ApplicationController
  # This is for the index action/ view
  def index
    @apartments = build_apartment_summaries
    @apartments = @apartments.paginate page: params[:page], per_page: 20
  end

  # This is for the visits action/ view by apartment id (property)
  def visits
    @apartment = Apartment.find(params[:id])

    @unit_visits = ApartmentUnitVisit
      .where(apartment_id: @apartment.id)
      .order(visited_at: :desc)

  end

  private

  def build_apartment_summaries
    summary_rows = fetch_summary_rows
    unit_names_by_apartment = group_unit_names_by_apartment

    summary_rows.map do |row|
      {
        apartment_id: row.apartment_id,
        apartment_name: row.apartment_name,
        visit_count: row.visit_count.to_i,
        visited_units: unit_names_by_apartment[row.apartment_id] || [],
        most_recent_visit: parse_timestamp(row.most_recent_visit)
      }
    end.sort_by { |a| a[:most_recent_visit] || Time.at(0) }.reverse
  end

  def fetch_summary_rows
    ApartmentUnitVisit
      .joins(:apartment)
      .select(
        "apartments.id AS apartment_id",
        "apartments.name AS apartment_name",
        "COUNT(*) AS visit_count",
        "MAX(apartment_unit_visits.visited_at) AS most_recent_visit"
      )
      .group("apartments.id, apartments.name")
  end

  def group_unit_names_by_apartment
    visits = ApartmentUnitVisit
      .select(:apartment_id, :building_name, :unit_number, :visited_at)
      .distinct

    formatted_units = visits.map do |visit|
      apartment_id = visit.apartment_id
      unit_name = format_unit_name(visit.building_name, visit.unit_number)
      [apartment_id, unit_name]
    end

    formatted_units
      .group_by(&:first)
      .transform_values do |pairs|
        pairs.map(&:last).uniq.sort_by(&:downcase)
      end
  end

  def format_unit_name(building, unit)
    b = building.presence
    u = unit.presence

    if b && u
      "#{b} - #{u}"
    elsif b
      b
    else
      u || ""
    end
  end

  def parse_timestamp(ts)
    ts&.to_time
  end
end