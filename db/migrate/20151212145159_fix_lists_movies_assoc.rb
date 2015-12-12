class FixListsMoviesAssoc < ActiveRecord::Migration
  def change
    remove_index :lists_movies, :movie_id
    remove_index :lists_movies, :list_id
    rename_table("lists_movies", "movie_lists")
  end
end
