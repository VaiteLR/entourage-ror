class CreateAdCards < ActiveRecord::Migration
  def change
    create_table :ad_cards do |t|
      t.string  :title,           null: false
      t.string  :sub_title
      t.string  :cta,             null: false
      t.string  :redirection_url, null: false
      t.string  :targeted_area,   null: false
      t.integer :ranking,         null: false
      t.string  :status,          null: false
      t.date    :start_date
      t.date    :end_date
      t.timestamps                null: false
    end
  end
end
