class Comment < ActiveRecord::Base
  belongs_to :trail
  validates :author, :presence => true
  validates :body, :presence => true
end
