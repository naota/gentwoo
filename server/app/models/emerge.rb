class Emerge < ActiveRecord::Base
  belongs_to :package
  belongs_to :user
  has_many :comments, :as => :commentable

  def fullname
    self.package.fullname
  end
  def page
    "emerges/" + self.id.to_s
  end
end
