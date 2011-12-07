class Package < ActiveRecord::Base
  has_many :emerges
  has_many :comment, :as => :commentable
  has_one :cache_pop_package

  def fullname
    category + "/" + name + "-" + version
  end
  def page
    "/packages/" + category + "/" + name + "/#" + version
  end
end
