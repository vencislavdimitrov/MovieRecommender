class Syncer

  class << self
    def perform(code)
      graph = Koala::Facebook::API.new(code)
      profile = graph.get_object("me")
      unless User.exists?(:fb_id => profile['id'])
        me = User.new()
        me.fb_id = profile['id']
        me.name = profile['name']
        me.save
      else
        me = User.find_by_fb_id profile['id']
      end

      myMovies = graph.get_connection('me', 'movies')
      myMovies.each do |myMovie|
        persist_movie myMovie, me
      end

      update_friends me, graph

      update_users_rank me, graph
    end

    def update_friends(me, graph)
      friends = graph.get_connection('me', 'friends')
      friends.each do |friend|
        unless User.exists?(:fb_id => friend['id'])
          user = User.new()
          user.fb_id = friend['id']
          user.name = friend['name']
          user.save
        else
          user = User.find_by_fb_id friend['id']
        end
        me.friendships.build(:friend_id => user.id).save

        friendMovies = graph.get_connection(friend['id'], 'movies')

        friendMovies.each do |friendMovie|
          persist_movie friendMovie, user
        end
      end
    end

    def update_users_rank(me, graph)
      Friendship.where(:user_id => me.id).update_all(:rank => 0)

      Thread.new do
        feeds = graph.get_connection('me', 'feed')
        while feeds.size > 0 do
          feeds.each do |feed|
            user = User.find_by(:fb_id => feed['from']['id'])
            if user
              relationship = me.friendships.where(:friend_id => user.id).first
              if relationship
                relationship.increment :rank
                relationship.save
              end
            end
            if feed['likes'].present? and feed['likes']['data'].present?
              feed['likes']['data'].each do |like|
                user = User.find_by(:fb_id => like['id'])
                if user
                  relationship = me.friendships.where(:friend_id => user.id).first
                  if relationship
                    relationship.increment :rank
                    relationship.save
                  end
                end
              end
            end
            if feed['comments'].present? and feed['comments']['data'].present?
              feed['comments']['data'].each do |like|
                user = User.find_by(:fb_id => like['id'])
                if user
                  relationship = me.friendships.where(:friend_id => user.id).first
                  if relationship
                    relationship.increment :rank
                    relationship.save
                  end
                end
              end
            end
          end
          feeds = feeds.next_page
        end
      end

      Thread.new do
        myMovies = graph.get_connection('me', 'movies')
        while myMovies.size > 0 do
          myMovies.each do |movie|
            movie = Movie.find_by(:fb_id => movie['id'])
            if movie
              movie.users.each do |user|
                relationship = me.friendships.where(:friend_id => user.id).first
                if relationship
                  relationship.increment :rank
                  relationship.save
                end
              end
            end
          end
          myMovies = myMovies.next_page
        end
      end
    end

    def persist_movie(fbMovie, user)
      unless Movie.exists?(:fb_id => fbMovie['id'])
        imdb_movie = Imdb::Search.new(fbMovie['name'])
        movie = Movie.new()
        movie.fb_id = fbMovie['id']
        movie.name = fbMovie['name']
        movie.users << user
        if imdb_movie && imdb_movie.movies.size > 0
          imdb_movie = imdb_movie.movies[0]
          movie.poster = imdb_movie.poster
          movie.poster_from_url(imdb_movie.poster)
          movie.plot = imdb_movie.plot_summary
          movie.genres = imdb_movie.genres.join(',').downcase
          movie.imdb_id = imdb_movie.id
          movie.release_date = imdb_movie.release_date
          movie.cast_members = imdb_movie.cast_members.first(5).join(',').downcase
          movie.rank = imdb_movie.rating
        end
        movie.save
      else
        movie = Movie.find_by(:fb_id => fbMovie['id'])
        unless movie.users.where(:id => user.id).count > 0
          Movie.update(movie.id, :users => movie.users << user)
        end
      end
    end
  end
end