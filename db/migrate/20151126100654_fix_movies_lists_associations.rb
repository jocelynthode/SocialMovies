class FixMoviesListsAssociations < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.remove_index :movie_id

    end

    create_table :lists_movies, id: false do |t|
      t.belongs_to :list, index: true
      t.belongs_to :movie, index: true
    end

  end
end
