module ApplicationHelper
  def logged?
    session["access_token"] ? true : false
  end
end
