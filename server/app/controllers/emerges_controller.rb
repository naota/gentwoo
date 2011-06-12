# -*- coding: utf-8 -*-
class EmergesController < ApplicationController
  before_filter :login_required, :only => [:my]

  def home
    @emerges = Emerge.order("buildtime DESC").limit(10)
    @erremerges = Emerge.where("duration=0").order("buildtime DESC").limit(10)
    @poppkg = Package.find(:all, 
                           :select => "count(emerges.id) AS cnt, packages.*",
                           :joins => :emerges,
                           :conditions => ["buildtime > ?", 7.day.ago],
                           :group => "package_id",
                           :order => "cnt DESC",
                           :limit => 10)
    @popperson = User.find(:all, 
                           :select => "count(emerges.id) AS cnt, users.*",
                           :joins => :emerges,
                           :conditions => ["buildtime > ?", 7.day.ago],
                           :group => "user_id",
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
                           :select => "count(emerges.id) AS cnt, packages.*",
                           :joins => :emerges,
                           :conditions => ["buildtime > ?", 7.day.ago],
                           :group => "package_id",
                           :order => "cnt DESC",
                           :limit => perpage,
                           :offset => page*perpage)
    count = Package.find(:all,
                         :select => "DISTINCT package_id",
                         :joins => :emerges,
                         :conditions => ["buildtime > ?", 7.day.ago]).count()
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
    @emerge = Emerge.find(params[:id])
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
    @emerge = Emerge.find(params[:id])
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
      @package = getPackage(params[:package])
      @emerge = @user.emerges.build(params[:emerge])
      @emerge.package = @package
      @emerge.tobe_tweet = @user.delay_emerge_tweet
    end
    
    respond_to do |format|
      if @emerge and @emerge.save
        if @user.tweet_emerged
          unless @user.delay_emerge_tweet
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
