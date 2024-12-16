class CreateApartmentUnitVisits < ActiveRecord::Migration[6.1]
  def change
    create_table :apartment_unit_visits do |t|
      t.string :building_name
      t.string :unit_number
      t.datetime :visited_at
      t.references :apartment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
