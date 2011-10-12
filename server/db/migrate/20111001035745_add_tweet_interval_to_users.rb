class AddTweetIntervalToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tweet_interval, :integer, :default => 10
    add_column :users, :last_tweet, :datetime
  end

  def self.down
    remove_column :users, :tweet_interval
    remove_column :users, :last_tweet
  end
end
