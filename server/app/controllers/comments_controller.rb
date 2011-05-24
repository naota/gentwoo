class CommentsController < ApplicationController
  before_filter :login_required, :only => [:create]

  def create
    @emerge = Emerge.find(params[:emerge_id])
    params[:comment][:user_id] = current_user
    @comment = @emerge.comments.create(params[:comment])
    redirect_to emerge_path(@emerge)
  end
end
