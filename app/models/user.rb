class User < ActiveRecord::Base
  has_and_belongs_to_many :movies
  has_many :friendships
  has_many :friends, :through => :friendships

  def rank
    friendships.rank
  end
end
