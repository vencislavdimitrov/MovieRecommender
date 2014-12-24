class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def logged?
    session["access_token"] ? true : false
  end

  def current_user
    if logged?
      id = @graph.get_object("me")['id']
      User.find_by_fb_id id
    else
      false
    end
  end
end
