class PackagesController < ApplicationController
  def showpackage
    @pkgs = Package.where(["category = ? AND name = ? AND version = ?",
                           params[:category], params[:name], params[:version]])
    respond_to do |format|
      format.html
    end
  end
end
