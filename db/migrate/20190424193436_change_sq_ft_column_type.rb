class ChangeSqFtColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :apartments, :sq_ft, :string
  end
end
