class EmergesController < ApplicationController
  # GET /emerges
  # GET /emerges.xml
  def index
    @emerges = Emerge.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emerges }
    end
  end

  # GET /emerges/1
  # GET /emerges/1.xml
  def show
    @emerge = Emerge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @emerge }
    end
  end

  # GET /emerges/new
  # GET /emerges/new.xml
  def new
    @emerge = Emerge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @emerge }
    end
  end

  # GET /emerges/1/edit
  def edit
    @emerge = Emerge.find(params[:id])
  end

  # POST /emerges
  # POST /emerges.xml
  def create
    @emerge = Emerge.new(params[:emerge])

    respond_to do |format|
      if @emerge.save
        format.html { redirect_to(@emerge, :notice => 'Emerge was successfully created.') }
        format.xml  { render :xml => @emerge, :status => :created, :location => @emerge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @emerge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /emerges/1
  # PUT /emerges/1.xml
  def update
    @emerge = Emerge.find(params[:id])

    respond_to do |format|
      if @emerge.update_attributes(params[:emerge])
        format.html { redirect_to(@emerge, :notice => 'Emerge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @emerge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /emerges/1
  # DELETE /emerges/1.xml
  def destroy
    @emerge = Emerge.find(params[:id])
    @emerge.destroy

    respond_to do |format|
      format.html { redirect_to(emerges_url) }
      format.xml  { head :ok }
    end
  end
end
