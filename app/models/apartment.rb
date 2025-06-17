class Apartment < ApplicationRecord
  # define has_many  
  has_many :apartment_unit_visits
end
