class ApartmentUnitVisitsController < ApplicationController
  def index
    @apartment_unit_visits = ApartmentUnitVisit.joins(:apartment).all.order("apartments.name, building_name, unit_number, visited_at desc")
  end
end
