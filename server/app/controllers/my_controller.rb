class MyController < ApplicationController
  before_filter :login_required
  def index
    @user = current_user
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def genToken()
    ActiveSupport::SecureRandom.hex(16)
  end

  def key
    @user = current_user
    unless @user.sitekey
      @user.sitekey = genToken()
      @user.save
    end

    respond_to do |format|
      format.html # key.html.erb
    end
  end

  def settings
    @user = current_user
    respond_to do |format|
      format.html
    end
  end


  def savesettings
    if true
      @user = current_user
      @user.tweet_emerged = params[:user][:tweet_emerged]
      @user.delay_emerge_tweet = params[:user][:delay_emerge_tweet]
      @user.tweet_comment = params[:user][:tweet_comment]
      @user.save
    end
    redirect_to "/my/settings"
  end
end
