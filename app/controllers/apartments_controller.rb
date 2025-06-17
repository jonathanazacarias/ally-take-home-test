class ApartmentsController < ApplicationController

  #create a method for the index action
  def index

    # build a "table" that has a summary of the apartment visits for a particular apartment name
    summary_rows = ApartmentUnitVisit
    .joins(:apartment)
    .select(
      "apartments.id AS apartment_id",
      "apartments.name AS apartment_name",
      "COUNT(*) AS visit_count",
      "MAX(apartment_unit_visits.visited_at) AS most_recent_visit"
    )
    # need to group visits together by apt id and name 
    # in order to get correct visit count and most recent visit
    .group("apartments.id, apartments.name")

  # use the summarized apartment visits to create a "table"
  # this is actually and array of hashes  where each hash has apt name, 
  # visit count, visited units list, most recent visit

  # .map do |row| ... end => for each row in summary_rows, run the block,
  # and collect the return value into a new array.
  @apartments = summary_rows.map do |row|

    # we need to get the list of visited units for each apartment name
    visited_units = ApartmentUnitVisit
      .where(apartment_id: row.apartment_id)
      .distinct
      .pluck(:building_name, :unit_number)
      # some of the data is missing either a building name or a unit number
      .map do |building, unit|
        building_str = building.presence || ""
        unit_str = unit.presence || ""
        "#{building_str} - #{unit_str}"
      end
      # we can just use the built in sort to sort the final unit names
      .sort_by { |name| name.downcase }
    
    # actually create the hash
    {
      apartment_name: row.apartment_name,
      visit_count: row.visit_count,
      visited_units: visited_units,
      most_recent_visit: row.most_recent_visit.present? ? Time.parse(row.most_recent_visit.to_s) : nil
    }
  end

    # we want to sort the final table by the apartment name with the most recent visit
    @apartments.sort_by! { |row| row[:most_recent_visit] || Time.at(0) }.reverse!
  end
end
