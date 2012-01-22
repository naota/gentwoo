class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true

  def page
    url_for(self.commentable, :anchor => "comment_" + self.id.to_s)
  end
end
