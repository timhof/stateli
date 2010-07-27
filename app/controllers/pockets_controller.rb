class PocketsController < ApplicationController
	
	
  before_filter :login_required
  
  # GET /pockets
  # GET /pockets.xml
  def index
    @pockets = Pocket.user_pockets(@current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pockets }
    end
  end

  # GET /pockets/1
  # GET /pockets/1.xml
  def show
    @pocket = Pocket.find_pocket(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pocket }
    end
  end

  # GET /pockets/new
  # GET /pockets/new.xml
  def new
    @pocket = Pocket.new

    respond_to do |format|
      format.js {render :action => 'new', :layout => false}
    end
  end

  # GET /pockets/1/edit
  def edit
    @pocket = Pocket.find_pocket(params[:id])
  end

  # POST /pockets
  # POST /pockets.xml
  def create
    @pocket = Pocket.new(params[:pocket])
	@pocket.user_id = @current_user.id
	
	 if params[:edit_pocket_commit].eql?('update')
      	success = @pocket.save
   		session[:selector].confirm_pocket_data(@current_user.id)
     end
      
    respond_to do |format|
      if success
        flash[:notice] = 'Pocket was successfully created.'
        @pockets = Pocket.user_pockets(@current_user.id)
        format.js {render :action => "update_available_pockets", :layout => false}
      end
    end
  end

  # PUT /pockets/1
  # PUT /pockets/1.xml
  def update
    @pocket = Pocket.find_pocket(params[:id])

    respond_to do |format|
      if @pocket.update_attributes(params[:pocket])
        flash[:notice] = 'Pocket was successfully updated.'
        format.html { redirect_to(@pocket) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pocket.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pockets/1
  # DELETE /pockets/1.xml
  def destroy
  	logger.info "INSIDE DESTROY"
    @pocket = Pocket.find(params[:id])
    @pocket.destroy
	@pockets = Pocket.user_pockets(@current_user.id)
    respond_to do |format|
    	logger.info "FORMAT #{format}"
        format.js {render :action => "update_available_pockets", :layout => false}
        format.html {render :action => "index"}
    end
  end
end
