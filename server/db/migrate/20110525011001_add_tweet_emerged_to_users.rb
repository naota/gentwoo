class AddTweetEmergedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tweet_emerged, :bool
    add_column :users, :tweet_comment, :bool
  end

  def self.down
    remove_column :users, :tweet_emerged
    remove_column :users, :tweet_comment
  end
end
