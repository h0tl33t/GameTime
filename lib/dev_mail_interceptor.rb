class DevMailInterceptor
	def self.delivering_email(message)
		message.subject = "#{message.to} #{message.subject}"
		message.to = "h0tl33t@gmail.com"
	end
end