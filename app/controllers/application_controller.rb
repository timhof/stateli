# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
	
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  
  def rescue_404
    rescue_action_in_public(ActionController::RoutingError)
  end
      
  
    
  def local_request?
    return false
  end
  
end
