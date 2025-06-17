class ApartmentUnitVisitsController < ApplicationController
  def index
    # SELECT "apartment_unit_visits".*
    # FROM "apartment_unit_visits"
    # INNER JOIN "apartment" ON "apartment"."apartment_id" = "apartment"."id"
    @apartment_unit_visits = ApartmentUnitVisit.joins(:apartment).all.order("apartments.name, building_name, unit_number, visited_at desc")
  end
end
