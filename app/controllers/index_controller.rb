class IndexController < ApplicationController

  before_action :setup

  APP_ID="502190246588002"
  APP_SECRET="c704d484ae2be236b6a4999db02a21b9"
  SITE_URL="http://localhost:3000/"

  def index
    # Syncer.perform session["access_token"]
  end

  def combined
    @movies = Movie.get_movies_combined(current_user).paginate(:page => params[:page], :per_page => 10, :total_entries => 300)
    render :index
  end

  def trusted
    @movies = Movie.get_movies_trust_based(current_user).paginate(:page => params[:page], :per_page => 10, :total_entries => 300)
    render :index
  end

  def collaborative
    @movies = Movie.get_movies_collaborative_based(current_user).paginate(:page => params[:page], :per_page => 10, :total_entries => 300)
    render :index
  end

  def login
    # generate a new oauth object with your app data and your callback url
    session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 'index/callback')
    #Koala::Facebook::OAuth.new(oauth_callback_url).

    # redirect to facebook to get your code
    redirect_to session[:oauth].url_for_oauth_code(:permissions => "user_likes, friends_likes, user_status, read_stream")

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
    redirect_to index_combined_path
  end

  def movie_watched_ajax
    movie = Movie.find_by_fb_id params['movie_id']
    trusted = Movie.get_movies_trust_based(current_user)
    collaborative = Movie.get_movies_collaborative_based(current_user)
    if trusted.index(movie) < collaborative.index(movie)
      FilterWeight.increment_trusted
    else
      FilterWeight.increment_collaborative
    end
    unless movie.users.where(:id => current_user.id).count > 0
      Movie.update(movie.id, :users => movie.users << current_user)
    end
    respond_to do |format|
      format.json  { render :json => '' }
    end
  end

  def setup
    ActiveRecord::Base.logger = nil
    @graph = Koala::Facebook::API.new(session["access_token"]) if session["access_token"]
  end

end
