class CreateApartments < ActiveRecord::Migration[5.2]
  def change
    create_table :apartments do |t|
      t.string :name
      t.string :address
      t.string :type
      t.decimal :price, precision: 10, scale: 2
      t.integer :sq_ft
      t.integer :unit_num
      t.string :bed_bath

      t.timestamps
    end
  end
end
