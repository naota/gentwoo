class Package < ActiveRecord::Base
  has_many :emerge
  def fullname
    category + "/" + name + "-" + version
  end
  def page
    "/packages/" + category + "/" + name + "/?version=" + version
  end
end
