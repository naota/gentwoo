class AddLoghashToEmerges < ActiveRecord::Migration
  def self.up
    add_column :emerges, :log_hash, :string
    add_column :emerges, :errorlog_hash, :string
  end

  def self.down
    remove_column :emerges, :log_hash
    remove_column :emerges, :errorlog_hash
  end
end
