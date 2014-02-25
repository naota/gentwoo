# -*- coding: utf-8 -*-
class EmergesController < ApplicationController
  before_filter :login_required, :only => [:my, :destroy, :remove]

  def home
    @emerges = Emerge.order("buildtime DESC").limit(10)
    @erremerges = Emerge.where("duration=0").order("buildtime DESC").limit(10)
    @poppkg = Package.find(:all, 
                           :select => "cache_pop_packages.cnt AS cnt, packages.*",
                           :joins => :cache_pop_package,
                           :order => "cnt DESC",
                           :limit => 10)
    @popperson = User.find(:all, 
                           :select => "cache_pop_users.cnt AS cnt, users.*",
                           :joins => :cache_pop_user,
                           :order => "cnt DESC",
                           :limit => 5)
    @recentcomments = Comment.order("created_at DESC").limit(5)
    respond_to do |format|
      format.html
    end
  end

  def poppackage
    perpage = 20
    page = params[:page].to_i || 0
    page = 0 if page < 0
    @poppkg = Package.find(:all, 
                           :select => "cache_pop_packages.cnt AS cnt, packages.*",
                           :joins => :cache_pop_package,
                           :order => "cnt DESC",
                           :limit => perpage,
                           :offset => page*perpage)
    count = Package.find(:all,
                         :select => "DISTINCT package_id",
                         :joins => :cache_pop_package).count()
    @prevpage = page - 1
    @nextpage = page + 1

    @prevpage = nil if @prevpage < 0
    @nextpage = nil if count < @nextpage * perpage

    @basecount = perpage * page

    respond_to do |format|
      format.html
    end
  end


  # GET /emerges
  # GET /emerges.xml
  def index
    perpage = 20
    page = params[:page].to_i || 0
    @emerges = Emerge.order("buildtime DESC").limit(perpage).offset(page*perpage)
    count = Emerge.count()
    @prevpage = page - 1
    @nextpage = page + 1

    @prevpage = nil if @prevpage < 0
    @nextpage = nil if count < @nextpage * perpage

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emerges }
    end
  end

  # GET /emerges/1
  # GET /emerges/1.xml
  def show
    @emerge = Emerge.unscoped.find(params[:id])
    @comments = @emerge.comments
    if (params[:type] == "ajax")
      @showcomment = false
      render :layout => "ajax"
    else
      @showcomment = true
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @emerge }
      end
    end
  end

  def ajaxerrorlog
    @emerge = Emerge.unscoped.find(params[:id])
    render :layout => 'ajax'
  end

  def useremerges
    @user = User.find_by_login(params[:name])
    if @user
      perpage = 20
      page = params[:page].to_i || 0
      @emerges = @user.emerges.order("buildtime DESC").limit(perpage).offset(page*perpage)
      count = @user.emerges.count()
      @prevpage = page - 1
      @nextpage = page + 1

      @prevpage = nil if @prevpage < 0
      @nextpage = nil if count < @nextpage * perpage

      respond_to do |format|
        format.html
      end
    else
      redirect_to "/404.html"
    end
  end

  def my
    redirect_to :controller => 'emerges',
                :action => 'useremerges',
                :name => current_user.login
  end

  def package
    @pkgs = Package.where(["category = ? AND name = ?",
                           params[:category], params[:name]]).order("version DESC")
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
    error = "Unknown error."
    @user = User.find_by_login(params[:user])
    @emerge = nil
    if @user.sitekey and @user.sitekey == params[:token]
      @package = getPackage(params[:package])
      @emerge = @user.emerges.build(params[:emerge])
      @emerge.package = @package
      @emerge.tobe_tweet = @user.tweet_emerged && (@user.tweet_interval != 0)
    else
      error = "Invalid key. Check your configuration."
    end
    
    if @emerge and @emerge.buildtime > 30.minutes.since
      @emerge = nil
      error = "Your clock stay in the feature!"
    end

    if @emerge
      dupcount = Emerge.count(:conditions =>
                              { :buildtime => @emerge.buildtime,
                                :duration => @emerge.duration,
                                :user_id => @emerge.user_id
                              })
      if dupcount > 0
        @emerge = nil
        error = "Duplicated record"
      end
    end

    respond_to do |format|
      if @emerge and @emerge.save
        if @user.tweet_emerged
          if @user.tweet_interval == 0
            stat = @package.fullname + 
              if @emerge.duration == 0
                "のemergeに失敗しました。"
              else
                "をemergeしました ("+@emerge.pretty_duration+")"
              end +
              " http://gentwoo.elisp.net"+@emerge.page+" #GenTwoo"
            @user.twitter.post('/statuses/update.json', :status => stat)
          end
        end
        format.xml  { render :xml => @emerge, :status => :created, :location => @emerge }
        format.json  {
          render :json => {"result" => "OK", "info" => ""}.to_json(),
            :status => :created, :location => @emerge }
      elsif @emerge
        format.xml  { render :xml => @emerge.errors, :status => :unprocessable_entity }
        format.json  {
          render :json => {"result" => "ERROR", "info" => @emerge.errors}.to_json(),
            :status => :created, :location => @emerge }
      else
        format.xml  { render :xml => "", :status => :unprocessable_entity }
        format.json  { 
          render :json => {"result" => "ERROR", "info" => error}.to_json(),
            :status => :created }
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

  def remove
    @emerge = Emerge.unscoped.find(params[:id])
    @comments = @emerge.comments
    @correct = current_user == @emerge.user
    confirmed = params[:confirm]
    
    respond_to do |format|
      if @correct
        if confirmed
          @emerge.destroy
          format.html {
            redirect_to(:controller => 'emerges',
                :action => 'useremerges',
                         :name => current_user.login) }
        else
          format.html
        end
      else
        format.html {
          redirect_to(:controller => 'emerges',
                       :action => 'show',
                       :id => @emerge) }
      end
    end
  end
end
