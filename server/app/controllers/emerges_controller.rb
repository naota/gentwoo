class EmergesController < ApplicationController
  before_filter :login_required, :only => [:my]

  def home
    @emerges = Emerge.order("buildtime DESC").limit(10)
    @erremerges = Emerge.where("duration=0").order("buildtime DESC").limit(10)
    @poppkg = Package.find(:all, 
                           :select => "count(emerges.id) cnt,*",
                           :joins => :emerge,
                           :conditions => ["buildtime > ?", 7.day.ago],
                           :group => "package_id",
                           :order => "cnt DESC",
                           :limit => 10)
    respond_to do |format|
      format.html
    end
  end

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

  def useremerges
    @user = User.find_by_login(params[:name])
    @emerges = @user.emerge.order("buildtime DESC")
    respond_to do |format|
      format.html
    end
  end

  def my
    redirect_to :controller => 'emerges',
                :action => 'useremerges',
                :name => current_user.login
  end

  def package
    @pkgs = Package.where(["category = ? AND name = ?",
                           params[:category], params[:name]])
    respond_to do |format|
      format.html
    end
  end

  def getPackage(pkg)
    @package = Package.where(["category = ? AND name = ? AND version = ?",
                              pkg[:category], pkg[:name], pkg[:version]]).first
    @package = Package.new(pkg) unless @package
    @package
  end

  # POST /emerges
  # POST /emerges.xml
  def create
    @user = User.find_by_login(params[:user])
    @emerge = nil
    if @user.sitekey and @user.sitekey == params[:token]
      then
        @package = getPackage(params[:package])
        @emerge = @user.emerge.build(params[:emerge])
        @emerge.package = @package
      end
    
    respond_to do |format|
      if @emerge and @emerge.save
        format.xml  { render :xml => @emerge, :status => :created, :location => @emerge }
        format.json  { render :json => @emerge, :status => :created, :location => @emerge }
      elsif @emerge
        format.xml  { render :xml => @emerge.errors, :status => :unprocessable_entity }
        format.json  { render :json => @emerge.errors, :status => :unprocessable_entity }
      else
        format.xml  { render :xml => "", :status => :unprocessable_entity }
        format.json  { render :json => "", :status => :unprocessable_entity }
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
