class IndexController < ApplicationController

  before_action :setup

  APP_ID="502190246588002"
  APP_SECRET="c704d484ae2be236b6a4999db02a21b9"
  APP_CODE="XXXX"
  SITE_URL="http://localhost:3000/"

  def index
    # if session['access_token']
    #   @face='You are logged in! <a href="index/logout">Logout</a>'
    #   # do some stuff with facebook here
    #   # for example:
    #   # @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
    #   # publish to your wall (if you have the permissions)
    #   # @graph.put_wall_post("I'm posting from my new cool app!")
    #   # or publish to someone else (if you have the permissions too ;) )
    #   # @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
    # else
    #   @face='<a href="index/login">Login</a>'
    # end
  end

  def login
    # generate a new oauth object with your app data and your callback url
    session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 'index/callback')
    #Koala::Facebook::OAuth.new(oauth_callback_url).

    # redirect to facebook to get your code
    redirect_to session[:oauth].url_for_oauth_code(:permissions => "user_likes, friends_likes")

  end

  def logout
    session['oauth'] = nil
    session['access_token'] = nil
    redirect_to index_index_path
  end

  #method to handle the redirect from facebook back to you
  def callback
    #get the access token from facebook with your code
    oauth = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 'index/callback')
    session['access_token'] = oauth.get_access_token(params[:code])

    Syncer.delay.perform session["access_token"]
    redirect_to index_index_path
  end

  # def index
  #   myMovies = @graph.get_connection('me', 'movies')
  #   myMoviesIds = []
  #   myMovies.each do |movie|
  #     myMoviesIds << movie['id']
  #   end
  #   @movies = Movie.where('fb_id not in (?)', myMoviesIds)
  #   @ranked_movies = @movies.order('rank desc')
  #   page = params[:page].present? ? params[:page].to_i : 1
  #   page = 1 if page < 1
  #   page = @ranked_movies.size / 5 if page > @ranked_movies.size / 5
  #   @ranked_movies = @ranked_movies.slice(5 * (page - 1), 5)
  # end

  def generate_movie_rank
    myMovies = @graph.get_connection('me', 'movies')
    myMoviesIds = []
    myMovies.each do |movie|
      myMoviesIds << movie['id']
    end
    movies = Movie.where('fb_id not in (?)', myMoviesIds)
    movies.each do |movie|
      movie.rank = movie.users.size + movie.users.sum(:rank)
      movie.save
    end
    redirect_to :root
  end

  def update_users_rank
    # me feed
    statuses = @graph.get_connection('me', 'statuses')
    statuses.each do |status|
      if status['likes'].present? and status['likes']['data'].present?
        status['likes']['data'].each do |like|
          user = User.find_by(:fb_id => like['id'])
          if user
            user.rank = user.rank + 1
            user.save
          end
        end
      end

      if status['comments'].present? and status['comments']['data'].present?
        status['comments']['data'].each do |like|
          user = User.find_by(:fb_id => like['id'])
          if user
            user.rank = user.rank + 1
            user.save
          end
        end
      end
    end

    myMovies = @graph.get_connection('me', 'movies')
    myMovies.each do |movie|
      movie = Movie.find_by(:fb_id => movie['id'])
      if movie
        movie.users.each do |user|
          user.rank = user.rank + 2
          user.save
        end
      end
    end

    redirect_to :root
  end

  def update_db
    friends = @graph.get_connection('me', 'friends')
    friends.each do |friend|
      unless User.exists?(:fb_id => friend['id'])
        user = User.new()
        user.fb_id = friend['id']
        user.name = friend['name']
        user.save
      else
        user = User.find_by_fb_id friend['id']
      end

      friendMovies = @graph.get_connection(friend['id'], 'movies')

      p friendMovies

      friendMovies.each do |friendMovie|
        unless Movie.exists?(:fb_id => friendMovie['id'])
          movie = Movie.new()
          movie.fb_id = friendMovie['id']
          movie.name = friendMovie['name']
          movie.users << user
          movie.save
        else
          movie = Movie.find_by(:fb_id => friendMovie['id'])
          Movie.update(movie.id, :users => movie.users << user)
        end
      end
    end

    redirect_to :root

  end

  def delete_db
    User.destroy_all
    Movie.destroy_all

    redirect_to :root
  end

  def setup
    ActiveRecord::Base.logger = nil
    @graph = Koala::Facebook::API.new(session["access_token"]) if session["access_token"]
  end

end
