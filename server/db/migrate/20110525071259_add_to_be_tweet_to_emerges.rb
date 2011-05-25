class AddToBeTweetToEmerges < ActiveRecord::Migration
  def self.up
    add_column :emerges, :tobe_tweet, :boolean, :default => false
    add_column :users, :delay_emerge_tweet, :boolean, :default => false
  end

  def self.down
    remove_column :emerges, :tobe_tweet
    remove_column :users, :delay_emerge_tweet
  end
end
