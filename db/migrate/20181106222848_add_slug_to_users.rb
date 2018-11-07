class AddSlugToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :slug, :string
    User.find_each { |u| u.update(slug: u.name.underscore) }
    add_index :users, :slug
  end
end
