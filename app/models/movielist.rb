class Movielist < ActiveRecord::Base
  belongs_to :movie
  belongs_to :list
end
