class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true

  def page
    self.commentable.page + "#comment_" + self.id.to_s
  end
end
