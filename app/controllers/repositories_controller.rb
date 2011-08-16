class RepositoriesController < ApplicationController
  # GET /repositories
  # GET /repositories.xml
  def index
    success = false
    @repositories = Repository.all
    if @repositories != nil
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @repositories }
      end
    else
      respond_to do |format|
        format.html # index.html.erb
        # TODO: need better response
        format.xml  { render :xml => '' }
      end
    end
  end

  # GET /repositories/1
  # GET /repositories/1.xml
  def show
    success = false
    @repository = Repository.find(params[:id])
    if @repository != nil
      success = @repository.save
    end
    
    if success
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @repository }
      end
    else
      respond_to do |format|
        format.html # show.html.erb
        # TODO: need better response
        format.xml  { render :xml => '' }
      end
    end
  end

  # GET /repositories/new
  # GET /repositories/new.xml
  def new
    @repository = Repository.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /repositories/1/edit
  def edit
    @repository = Repository.find(params[:id])
  end

  # POST /repositories
  # POST /repositories.xml
  def create
    success = false
    @repository = Repository.new(params[:repository])
    if @repository != nil
      success = @repository.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to(@repository, :notice => 'Repository was successfully created.') }
        format.xml  { head :ok }
      elsif @repository != nil
        format.html { render :action => "new" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }        
      else
        format.html { render :action => "index" }
        # TODO: need better response
        format.xml  { render :xml => '', :status => :unprocessable_entity }
      end
    end
  end

  # PUT /repositories/1
  # PUT /repositories/1.xml
  def update
    success = false
    @repository = Repository.find(params[:id])
    if @repository != nil
      success = @repository.update_attributes(params[:repository])
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to(@repository, :notice => 'Repository was successfully updated.') }
        format.xml  { head :ok }
      elsif @repository != nil
        format.html { render :action => "edit" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }        
      else
        format.html { render :action => "index" }
        # TODO: need better response
        format.xml  { render :xml => '', :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.xml
  def destroy
    @repository = Repository.find(params[:id])
    if @repository != nil
      Score.find_by_repository_id(@repository[:id]).each do |score|
        Score.delete(score)
      end
      @repository.destroy
    end

    respond_to do |format|
      format.html { redirect_to(repositories_url) }
      format.xml  { head :ok }
    end
  end
end
