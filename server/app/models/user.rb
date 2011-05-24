class User < TwitterAuth::GenericUser
  has_many :emerge
  def link
    "users/" + self.login
  end
end
