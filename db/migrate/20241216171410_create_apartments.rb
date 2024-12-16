class CreateApartments < ActiveRecord::Migration[6.1]
  def change
    create_table :apartments do |t|
      t.string :name

      t.timestamps
    end
  end
end
