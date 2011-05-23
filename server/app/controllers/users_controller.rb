class UsersController < ApplicationController
  def show
    @user = User.find_by_login(params[:name])
    @emerges = @user.emerge.all
    respond_to do |format|
      format.html
    end
  end
end
