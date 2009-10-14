ActionController::Routing::Routes.draw do |map|
	
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'stateli', :action => 'register'
  map.signup '/signup', :controller => 'stateli', :action => 'signup'
 
  map.cancel_popup '/cancel', :controller => "stateli", :action => "cancel_popup", :conditions => {:method => :get}
  
  map.listing '/listing', :controller => "stateli", :action => "account_listing"
  map.history '/account/:id/history', :controller => "stateli", :action => "account_history"
  map.pending '/account/:id/pending', :controller => "stateli", :action => "account_pending"
  map.account_new '/new_account', :controller => "stateli", :action => "account_new_account", :conditions => {:method => :get}
  map.account_create '/new_account', :controller => "stateli", :action => "account_create_account", :conditions => {:method => :post}
   map.account_details '/account_details/:id', :controller => "stateli", :action => "account_details"
    map.account_edit '/update_account/:account_id', :controller => "stateli", :action => "account_edit", :conditions => {:method => :get}
  map.account_update '/update_account/:account_id', :controller => "stateli", :action => "account_update", :conditions => {:method => :put}
  
  
  map.execute_deposit '/account/:id/deposit', :controller => "stateli", :action => "execute_deposit", :conditions => {:method => :post}
  map.deposit '/account/:id/deposit', :controller => "stateli", :action => "account_deposit", :conditions => {:method => :get}
  map.execute_withdraw '/account/:id/withdraw', :controller => "stateli", :action => "execute_withdraw", :conditions => {:method => :post}
  map.withdraw '/account/:id/withdraw', :controller => "stateli", :action => "account_withdraw", :conditions => {:method => :get}
  map.journal '/account/:id/journal', :controller => "stateli", :action => "account_journal"
  map.account_journal_flex '/account_journal_flex.:format', :controller => "stateli", :action => "account_journal_flex", :conditions => {:method => :get}
  map.account_pending_flex '/account_pending_flex.:format', :controller => "stateli", :action => "account_pending_flex", :conditions => {:method => :get}
   map.total_journal_flex '/total_journal_flex.:format', :controller => "stateli", :action => "total_journal_flex", :conditions => {:method => :get}
   map.total_pending_flex '/total_pending_flex.:format', :controller => "stateli", :action => "total_pending_flex", :conditions => {:method => :get}
  
  map.expense_listing '/expense_listing', :controller => "stateli", :action => "expense_listing"
  map.income_listing '/income_listing', :controller => "stateli", :action => "income_listing"
  map.contract_credit '/contract_credit', :controller => "stateli", :action => "contract_credit", :conditions => {:method => :get}
  map.build_contract_credit '/contract_credit', :controller => "stateli", :action => "build_contract_credit", :conditions => {:method => :post}
  map.contract_debit '/contract_debit', :controller => "stateli", :action => "contract_debit", :conditions => {:method => :get}
  map.build_contract_debit '/contract_debit', :controller => "stateli", :action => "build_contract_debit", :conditions => {:method => :post}
  map.contract_details '/contract_details/:id', :controller => "stateli", :action => "contract_details"
  
  map.transactions_pending 'pending_transactions', :controller => "stateli", :action => "transactions_pending"
  
  map.transaction_details '/transaction_details/:id', :controller => "stateli", :action => "transaction_details"
  map.transaction_autopay '/autopay/:transaction_id', :controller => "stateli", :action => "autopay"
  map.clean_transactions '/clean_transactions/', :controller => "stateli", :action => "clean_transactions"
  
  map.transaction_edit '/update_transaction/:transaction_id', :controller => "stateli", :action => "transaction_edit", :conditions => {:method => :get}
  map.transaction_update '/update_transaction/:transaction_id', :controller => "stateli", :action => "transaction_update", :conditions => {:method => :put}
  
  map.transaction_do'/complete_transaction/:transaction_id', :controller => "stateli", :action => "transaction_do", :conditions => {:method => :get}
  map.transaction_complete '/complete_transaction/:transaction_id', :controller => "stateli", :action => "transaction_complete", :conditions => {:method => :put}
  
   map.transaction_destroy '/remove_transaction/:transaction_id', :controller => "stateli", :action => "transaction_remove", :conditions => {:method => :delete}
  
   map.resources :users

  map.resource :session

  map.resources :contracts do |contracts| 
  	contracts.resources :history 
  	contracts.resources :pending 
  end
  
  map.resources :transactions
  
  map.resources :accounts
  
 
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
