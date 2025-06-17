class Apartment < ApplicationRecord
  # define relation between an apartment and apartment unit visits as has_many  
  has_many :apartment_unit_visits
end
