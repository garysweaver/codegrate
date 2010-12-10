class Score < ActiveRecord::Base
  
  has_one :author
  has_one :repository
  
end
