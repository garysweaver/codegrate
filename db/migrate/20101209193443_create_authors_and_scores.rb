class CreateAuthorsAndScores < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
    
    create_table :scores do |t|
      t.string :repository_id
      t.string :author_id
      t.date :date
      t.integer :score
      t.string :commit

      t.timestamps
    end
  end

  def self.down
    drop_table :scores
    drop_table :authors
  end
end
