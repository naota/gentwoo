class Emerge < ActiveRecord::Base
  belongs_to :package
  belongs_to :user
  has_many :comments, :as => :commentable

  def page
    "emerges/" + self.id.to_s
  end
end
