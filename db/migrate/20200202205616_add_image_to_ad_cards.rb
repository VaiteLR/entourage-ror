class AddImageToAdCards < ActiveRecord::Migration
  def change
    add_column :ad_cards, :image, :string
    #change_column_null :ad_cards, :image, false
  end
end
