module ApplicationHelper
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
