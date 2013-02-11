class Comment < ActiveRecord::Base
  belongs_to :user
  attr_accessible :action, :category, :text, :user_id
end
