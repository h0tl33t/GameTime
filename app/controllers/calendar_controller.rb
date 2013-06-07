class CalendarController < ApplicationController
  
  def index
    @month = (params[:month] || (Time.zone || Time).now.month).to_i
    @year = (params[:year] || (Time.zone || Time).now.year).to_i

    @shown_month = Date.civil(@year, @month)
	
	my_events = current_player.events.event_strips_for_month(@shown_month)
	my_availabilities = current_player.availabilities.event_strips_for_month(@shown_month)
	
	friends_availabilities = []
	current_player.friendships.mutual.each do |friendship|
		friends_availabilities.concat(friendship.friend.availabilities.event_strips_for_month(@shown_month))
	end
	
    @event_strips = my_events + my_availabilities + friends_availabilities
  end
  
end
