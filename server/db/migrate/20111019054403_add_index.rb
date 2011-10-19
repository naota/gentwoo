class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :emerges, :buildtime
    add_index :emerges, :package_id
    add_index :emerges, :user_id
  end

  def self.down
    remove_index :emerges, :buildtime
    remove_index :emerges, :package_id
    remove_index :emerges, :user_id
  end
end
