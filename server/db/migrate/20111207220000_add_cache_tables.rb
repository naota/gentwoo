class AddCacheTables < ActiveRecord::Migration
  def self.up
    create_table :cache_pop_packages do |t|
      t.integer :cnt
      t.references :package
      t.datetime :created_at
    end
    add_index :cache_pop_packages, :cnt

    create_table :cache_pop_users do |t|
      t.integer :cnt
      t.references :user
      t.datetime :created_at
    end
    add_index :cache_pop_users, :cnt
  end

  def self.down
    drop_table :cache_pop_packages
    drop_table :cache_pop_users
  end
end
