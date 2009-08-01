# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def show_popup_form(form_partial)
		page[:listing_form].replace_html :partial => form_partial
		page[:listing_form_div].show
	
		page.select("a.listing_link").each { |div| div.hide}
		page[:navigation].hide
		page[:navigation_disabled].show
		page[:flashdiv].replace_html ""
		page << "if($('login_form_div')){"
			page[:login_form_div].hide
		page << "}"
	end
	
	def hide_popup_form
		page[:listing_form].replace_html ""
		page << "if($('listing_form_div').visible()){"
			page[:listing_form_div].visual_effect(:blindUp, :duration => 1)
		page << "}"
		page[:listing_form_div].hide
		page.select("a.listing_link").each { |div| div.show}
		page << "if($('welcome_div')){"
			page[:navigation].show
			page[:navigation_disabled].hide
		page << "}"
		
		page << "if($('login_form_div')){"
			page[:login_form_div].show
		page << "}"

	end
	
	def onclick_to_remote(options = {}) 
		*args = remote_function(options) 
		function = args[0] || '' 
		function = update_page(&block) if block_given? 
		"onclick=\"#{function}; return false;\"" 
	end
	
	def real_currency(number)
		number_to_currency(number, :delimiter => ",", :unit => "$ ", :separator => ".")
	end
end