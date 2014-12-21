class Syncer

  def self.perform(code)
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

    update_friends me, graph

    update_users_rank me, graph
  end

  def self.update_friends(me, graph)
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
        unless Movie.exists?(:fb_id => friendMovie['id'])
          movie = Movie.new()
          movie.fb_id = friendMovie['id']
          movie.name = friendMovie['name']
          movie.users << user
          movie.save
        else
          movie = Movie.find_by(:fb_id => friendMovie['id'])
          unless movie.users.where(:id => user.id).count > 0
            Movie.update(movie.id, :users => movie.users << user)
          end
        end
      end
    end
  end

  def self.update_users_rank(me, graph)
    me.friendships.each do |friendship|
      friendship.rank = 0
      friendship.save
    end
    statuses = graph.get_connection('me', 'statuses')
    statuses.each do |status|
      if status['likes'].present? and status['likes']['data'].present?
        status['likes']['data'].each do |like|
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

      if status['comments'].present? and status['comments']['data'].present?
        status['comments']['data'].each do |like|
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

    myMovies = graph.get_connection('me', 'movies')
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
  end
end