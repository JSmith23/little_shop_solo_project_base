class AddSlugToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :slug, :string
    Item.find_each { |i| i.update(slug: i.name.underscore) }
    add_index :items, :slug
  end
end
