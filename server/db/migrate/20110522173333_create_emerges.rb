class CreateEmerges < ActiveRecord::Migration
  def self.up
    create_table :emerges do |t|
      t.datetime :buildtime
      t.integer :duration
      t.references :package
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :emerges
  end
end
