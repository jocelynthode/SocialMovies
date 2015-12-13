class ChangeMovielistsTableName < ActiveRecord::Migration
  def change
    rename_table("movie_lists", "movielists")
  end
end
