class RemoveMidFromMovies < ActiveRecord::Migration
  def change
    remove_column :movies, :mid, :number
  end
end
