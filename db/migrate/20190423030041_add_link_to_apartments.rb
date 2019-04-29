class AddLinkToApartments < ActiveRecord::Migration[5.2]
  def change
    add_column :apartments, :link, :string
  end
end
