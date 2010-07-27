# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def show_popup_form(form_partial)
		page[:listing_form].replace_html :partial => form_partial
		page[:listing_form_div].show
	
		page.select("a.listing_link").each { |div| div.hide}
		page[:navigation_enabled].hide
		page[:navigation_disabled].show
		page[:flashdiv].replace_html ""
		page[:flashdiv].show
		page << "if($('login_form_div')){"
			page[:login_form_div].hide
		page << "}"
		page << "Form.focusFirstElement($('listing_form_form'))"
			
	end
	
	def hide_popup_form (message=nil)
		page[:listing_form].replace_html ""

		page[:listing_form_div].hide
		page.select("a.listing_link").each { |div| div.show}
		page << "if($('logout_div')){"
			page[:navigation_disabled].hide
			page[:navigation_enabled].show
		page << "}"
		
		page << "if($('login_form_div')){"
			page[:login_form_div].show
		page << "}"
		
		unless message.nil?
			page[:flashdiv].replace_html message
			page[:flashdiv].visual_effect(:fade, :duration => 2)
			#flash.discard
		end
	end
	
	def update_transactions (transactions, mainPage)
		
		showBalance = mainPage == StateliHelper::MAIN_PAGE_JOURNAL_ACCOUNTS
		showContract = mainPage != StateliHelper::MAIN_PAGE_JOURNAL_CONTRACTS && mainPage != StateliHelper::MAIN_PAGE_PENDING_CONTRACTS
		showAccount = mainPage != StateliHelper::MAIN_PAGE_JOURNAL_ACCOUNTS && mainPage != StateliHelper::MAIN_PAGE_PENDING_ACCOUNTS
	
		page << "if($('transactions')){"
		page[:transactions].replace_html :partial =>"transactions/transactions_listing", :locals => {:showBalance => showBalance, :showContract => showContract, :showAccount => showAccount}, :collection => transactions, :as => :transaction
		page << "}"
	end
	
	def onclick_to_remote(options = {}) 
		*args = remote_function(options) 
		function = args[0] || '' 
		function = update_page(&block) if block_given? 
		"onclick=\"#{function}; return false;\"" 
	end
	
	def real_currency(number)
		if number.nil?
			""
		#elsif number < 0
		#	number_to_currency(0-number, :delimiter => ",", :unit => "$", :separator => ".", :format => "%u %n")
		#else
		#	number_to_currency(number, :delimiter => ",", :unit => "$", :separator => ".", :format => "%u %n")
		#end
		else
		  number_to_currency(number, :delimiter => ",", :unit => "", :separator => ".", :format => "%u %n")
		end
	end
	
	def parseCurrency(dollar_str)
		return dollar_str.gsub("$","").gsub(",","").to_f
	end
end