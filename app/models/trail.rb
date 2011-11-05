class Trail < ActiveRecord::Base

  has_many :comments, :dependent => :destroy

  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
