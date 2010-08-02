# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
	
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :init_selector
  
  helper_method :selector
  
  def selector
  	@selector ||= session[:selector]
  end
  
  def selector=(selector)
  	session[:selector] = selector
  end
  
  def rescue_404
    rescue_action_in_public(ActionController::RoutingError)
  end
      
  def local_request?
    return false
  end
  
  private
  def init_selector
  	session[:selector] ||= Selector.new
  end
  
end
