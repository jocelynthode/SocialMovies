class DropMovielistsTable < ActiveRecord::Migration
  def change
    drop_table :movielists

    create_table(:movielists) do |t|
      t.references :list
      t.references :movie
    end
  end
end
