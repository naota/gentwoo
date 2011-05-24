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
end
