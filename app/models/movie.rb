class Movie < ActiveRecord::Base
  has_and_belongs_to_many :users

  def movie_rank(user)
    users.select(user.friendships).joins('inner join friendships on friendships.friend_id = users.id').pluck('sum(friendships.rank)')
  end

  def self.get_movies_trust_based(user)
    Movie.
        where('users.id in (?)' , user.friendships.pluck(:friend_id)).
        where('movies.id not in (?)', user.movies.pluck(:id)).
        joins(:users).
        joins('inner join friendships on friendships.friend_id = users.id').
        select('movies.*, sum(friendships.rank) as movie_rank').
        group('movies.id').
        order('movie_rank desc')
  end

  def self.get_movies_collaborative_based(user)
    Movie.
        where('movies.id not in (?)', user.movies.pluck(:id)).
        joins(:users).
        select('movies.*, (count(*) + movies.rank) as movie_rank').
        group('movies.id').
        order('movie_rank desc')
  end

  def poster
    read_attribute(:poster) || ActionController::Base.helpers.asset_path('movie_no_poster.png')
  end
end
