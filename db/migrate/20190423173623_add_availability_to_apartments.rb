class AddAvailabilityToApartments < ActiveRecord::Migration[5.2]
  def change
    add_column :apartments, :availability, :string
  end
end
