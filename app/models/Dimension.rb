class Dimension < ActiveRecord::Base

  has_many :dimension_options, inverse_of: :dimension
  has_many :skill_details, inverse_of: :dimension, order: "user_id, skill_id, dimension_id"
  has_many :users, through: :skill_details, uniq: true, order: "users.email"
  has_many :skills, through: :skill_details, uniq: true, order: "skills.sort_order"

  attr_accessible :code, :label, :description, :sort_order

  SEED_VALUES = [
    { code: "level", label: "Skill Level", description: nil, sort_order: 100},
    { code: "status", label: "Status", description: nil, sort_order: 200},
    { code: "satisfaction", label: "Satisfaction", description: nil, sort_order: 300},
    { code: "passion", label: "Passion", description: nil, sort_order: 400},
    { code: "synergy", label: "Synergy", description: nil, sort_order: 500}
  ]

  def self.seed(overwrite = false)
    SEED_VALUES.each do |item|
      record = find_or_create_by_code item[:code], item
      record.update_attributes! item if overwrite
    end
  end

end