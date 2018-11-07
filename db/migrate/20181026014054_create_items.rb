class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :description
      t.string :image
      t.float :price
      t.integer :inventory
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
