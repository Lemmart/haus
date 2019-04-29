class ChangeApartmentTableColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :apartments, :price, :string
  end
end
