class FixListTable < ActiveRecord::Migration
  def change
    remove_column :lists, :movie_id, :integer
  end
end
