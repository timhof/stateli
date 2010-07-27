class Selector
		attr_accessor :selectedPockets, 
					  :pocketIdNameMap
					  
					  
	def initialize
		initialize_pockets
	end
	
	def initialize_pockets(select_all=true, user_id=nil)
		if select_all
			@selectedPockets = {}
		end
		@pocketIdNameMap = {}
		pockets = Pocket.find(:all)
		pockets << Pocket.unclassified
  		pockets.each do |pocket| 
  			if select_all
  				@selectedPockets[pocket.id] = '1'
  			end
  			@pocketIdNameMap[pocket.id] = pocket.name
  		end
	end
	
	def confirm_pocket_data(user_id=nil)
		initialize_pockets(false, user_id)
	end
	
end
