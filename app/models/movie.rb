require "open-uri"
class Movie < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def movie_rank(user)
    trusted_rank = users.select(user.friendships).joins('inner join friendships on friendships.friend_id = users.id').pluck('sum(friendships.rank)')[0]
    collaborative_rank = users.count + rank

    trusted_rank * FilterWeight.get_trusted_ratio + collaborative_rank * FilterWeight.get_collaborative_ratio
  end

  def poster
    read_attribute(:poster) || ActionController::Base.helpers.asset_path('movie_no_poster.png')
  end

  def title
    if release_date.present?
      "#{name} (#{release_date.year})"
    else
      name
    end
  end

  def rank
    read_attribute(:rank) || 0
  end

  def recommended_by_friends_of(current_user)
    if current_user.present?
      users.where('users.id in (?)', current_user.friendships.pluck(:friend_id)).order(:rank => :desc).pluck(:name)
    else
      users.order(:rank => :desc).pluck(:name)
    end
  end

  def poster_from_url(url)
    self.image = open(url)
  end

  class << self
    def get_movies_trust_based(user)
      Movie.
          where('users.id in (?)', user.friendships.pluck(:friend_id)).
          where('movies.id not in (?)', user.movies.pluck(:id)).
          joins(:users).
          joins('inner join friendships on friendships.friend_id = users.id').
          select("movies.*, sum(friendships.rank) as movie_rank").
          group('movies.id').
          order('movie_rank desc').
          limit(200)
    end

    def get_movies_collaborative_based(user)
      Movie.
          where('movies.id not in (?)', user.movies.pluck(:id)).
          joins(:users).
          select("movies.*, (count(*) + movies.rank) as movie_rank").
          group('movies.id').
          order('movie_rank desc').
          limit(200)
    end

    def get_movies_collaborative
      Movie.
          joins(:users).
          select("movies.*, count(*) as movie_rank").
          group('movies.id').
          order('movie_rank desc').
          limit(200)
    end

    def get_movies_combined(user)
      (Movie.get_movies_collaborative_based(user) + Movie.get_movies_trust_based(user)).sort_by { |movie| movie.movie_rank user }.reverse.uniq
    end
  end

end
