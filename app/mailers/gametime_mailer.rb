class GametimeMailer < ActionMailer::Base
	default from: 'gametime.notifications@gmail.com'
	
	def welcome_new_player(player)
		@player = player
		mail(to: "#{player.name} <#{player.email}>", subject: 'Welcome to GameTime!')
	end
	
	def pending_friend_request(player, requesting_player)
		@player = player
		@friend = requesting_player
		mail(to: "#{player.name} <#{player.email}>", subject: 'GameTime: Pending Friend Request')
	end
	
	def gametime_event_created(event)
		@event = event
		formatted_emails = event.players.map {|p| "#{p.name} <#{p.email}>"}
		mail(to: formatted_emails, subject: 'GameTime: Event Created')
	end
	
	def gametime_event_reminder(event)
		@event = event
		formatted_emails = event.players.map {|p| "#{p.name} <#{p.email}>"}
		mail(to: formatted_emails, subject: "GameTime: Upcoming Event Reminder - #{event.name}")
	end
end