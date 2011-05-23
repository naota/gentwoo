class Package < ActiveRecord::Base
  has_many :emerge
  def fullname
    category + "/" + name + "-" + version
  end
end
