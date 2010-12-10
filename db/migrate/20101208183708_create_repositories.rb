class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name
      t.string :repository_type
      t.string :uri

      t.timestamps
    end
  end

  def self.down
    drop_table :repositories
  end
end
