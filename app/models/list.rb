class List < ActiveRecord::Base
  has_many :movielists
  has_many :movies, through: :movielists
  belongs_to :user
  acts_as_followable
end
