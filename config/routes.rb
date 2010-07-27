ActionController::Routing::Routes.draw do |map|
  map.resources :pockets

	
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  
  map.register '/register', :controller => 'users', :action => 'register'
  map.signup '/signup', :controller => 'users', :action => 'signup'
 
  map.account_delete_transaction '/account/:account_id/delete_transaction/:id', :controller => "transactions", :action => "destroy"
  map.account_remove_all_transactions '/account/:id/delete_all', :controller => "accounts", :action => "delete_all_transactions"
   map.account_delete_transactions '/account/:account_id/delete_checked', :controller => "transactions", :action => "delete_checked"
   
  map.resources :accounts
  
  map.resources :accounts do |account|
  	account.resources :rules
  	account.resources :transactions
  	account.resources :contracts
  end
  
  map.account_journal '/account/:id/journal', :controller => "accounts", :action => "journal"
  
  map.account_month_pocket_journal '/account/:id/month_pocket_journal/:pocket_id/:yrMonth', :controller => "accounts", :action => "month_pocket_journal"
  map.account_apply_rules '/account/:id/apply_rules', :controller => "accounts", :action => "apply_rules"
  map.account_deposit '/account/:id/deposit', :controller => "accounts", :action => "deposit", :conditions => {:method => :get}
  map.account_withdraw '/account/:id/withdraw', :controller => "accounts", :action => "withdraw", :conditions => {:method => :get}
  map.account_execute_transaction '/account/:id/execute_transaction/:type', :controller => "accounts", :action => "execute_transaction", :conditions => {:method => :post}
   map.account_upload_file '/account/:id/upload_file', :controller => "accounts", :action => "upload_file", :conditions => {:method => :post}
  map.account_show_upload '/account/:id/show_upload', :controller => "accounts", :action => "show_upload", :conditions => {:method => :get}
  
  map.month_pocket_totals '/account/:id/month_pocket_totals', :controller => "accounts", :action => "month_pocket_totals"
  
  map.contract_journal '/contract/:id/journal', :controller => "contracts", :action => "journal"
  
  map.transaction_autopay '/transaction/:id/autopay', :controller => "transactions", :action => "autopay"
  map.transaction_complete '/transaction/:id/complete', :controller => "transactions", :action => "complete", :conditions => {:method => :get}
 
   
   map.resources :users

  map.resource :session

  map.root :controller => "stateli", :action => "index"
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"


  map.connect '*path', :controller => 'application', :action => 'rescue_404' unless ::ActionController::Base.consider_all_requests_local 
end
