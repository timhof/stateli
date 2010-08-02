class RulesController < ApplicationController
	
  before_filter :login_required
	  
  # GET /rules
  # GET /rules.xml
  def index
	@account = Account.find(params[:account_id])
    @rules = @account.rules
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rules }
    end
  end

  # GET /rules/1
  # GET /rules/1.xml
  def show
    @rule = Rule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rule }
    end
  end

  # GET /rules/new
  # GET /rules/new.xml
  def new
    @rule = Rule.new
	@account = Account.find(params[:account_id])
	@pockets = Pocket.user_pockets(@current_user.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rule }
    end
  end

  # GET /rules/1/edit
  def edit
    @rule = Rule.find(params[:id])
	@account = Account.find(params[:account_id])
	@pockets = Pocket.user_pockets(@current_user.id)
  end

  # POST /rules
  # POST /rules.xml
  def create
  	
    @rule = Rule.build_rule(params[:rule])
	@account = Account.find(params[:account_id])
	@rule.account = @account
	@rule.user_id = @current_user.id
	@rule.pocket_id = params[:prefix][:pocket_id]
    respond_to do |format|
    	
      if params[:commit].eql?('Create') && @rule.save
        flash[:notice] = 'Rule was successfully created.'
        format.html { redirect_to(account_rules_url(@account)) }
        format.xml  { render :xml => @rule, :status => :created, :location => @rule }
      elsif params[:commit].eql?('Cancel')
      	format.html { redirect_to(account_rules_url(@account)) }
 	  else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rules/1
  # PUT /rules/1.xml
  def update
    @rule = Rule.find(params[:id])
	@account = Account.find(params[:account_id])
    params[:rule][:pocket_id] = params[:prefix][:pocket_id]
    respond_to do |format|
      if params[:commit].eql?('Cancel') || @rule.update_attributes(params[:rule])
        format.html { redirect_to(account_rules_url(@account)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.xml
  def destroy
    @rule = Rule.find(params[:id])
    
	@account = Account.find(params[:account_id])
    @rule.destroy

    respond_to do |format|
      format.html { redirect_to(account_rules_url(@account)) }
      format.xml  { head :ok }
    end
  end
end
