class PagesController < ActionController::Base
  layout "application"
  def home
	@title = 'Home'
  end
end