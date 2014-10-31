class Subkast
  include Mongoid::Document

  field :name, type: String
  field :code, type: String
  field :url, type: String

  def self.by_user(user)
    return all if user.nil?
    self.in(code: user.my_subkasts)
  end

  def serializable_hash(opts)
    {
      name: name,
      code: code,
      slug: url
    }
  end
end
