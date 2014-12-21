class Syncer

  def self.perform(code)
    graph = Koala::Facebook::API.new(code)
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
          Movie.update(movie.id, :users => movie.users << user)
        end
      end
    end
  end
end