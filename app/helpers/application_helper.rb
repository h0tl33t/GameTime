module ApplicationHelper
	def title
		base_title = 'GameTime'
		if @title.empty?
			base_title
		else
			"#{base_title} - #{@title}"
		end
	end
end
