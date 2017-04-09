class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.timestamps
      t.string :brand
      t.string :name
      t.float :price
      t.string :url
      t.string :image
      t.string :asin
    end
  end
end
