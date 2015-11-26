class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.integer :mid

      t.timestamps null: false
    end
  end
end
