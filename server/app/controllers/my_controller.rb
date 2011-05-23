class MyController < ApplicationController
  before_filter :login_required
  def index
    @user = current_user
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def key
    @user = current_user
    respond_to do |format|
      format.html # key.html.erb
    end
  end

  def emerges
    @emerges = current_user.emerge.all
    respond_to do |format|
      format.html # key.html.erb
    end
  end
end
