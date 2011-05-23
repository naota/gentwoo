class Emerge < ActiveRecord::Base
  belongs_to :package
  belongs_to :user

  def page
    "/emerges/" + self.id.to_s
  end
end
