class SkillDetail < ActiveRecord::Base
  belongs_to :user, inverse_of: :skill_details
  belongs_to :skill, inverse_of: :skill_details
  belongs_to :dimension, inverse_of: :skill_details
  attr_accessible :user, :skill, :dimension, :value
end