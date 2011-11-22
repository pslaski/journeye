class Trail < ActiveRecord::Base

  validates :name,  :presence => true, :uniqueness => true
  validates :locations,  :presence => true
  has_many :comments, :dependent => :destroy

  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
