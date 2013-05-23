module ApplicationHelper
	def title
		base_title = 'GameTime'
		unless @title
			base_title
		else
			"#{base_title} - #{@title}"
		end
	end
end
