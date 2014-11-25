class Subkast
  include Mongoid::Document

  field :name, type: String
  field :code, type: String
  field :url, type: String

  def self.by_user(user)
    return all if user.nil?
    self.in(code: user.my_subkasts)
  end

  def slug
    url
  end

  def self.by_slug(slug)
    Subkast.where(url: slug).first
  end

  def serializable_hash(opts)
    {
      name: name,
      code: code,
      slug: url
    }
  end
end
