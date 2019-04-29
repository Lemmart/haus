class ChangeApartmentTableColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :apartments, :type, :style
  end
end
