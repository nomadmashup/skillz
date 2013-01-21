class Skill < ActiveRecord::Base

  has_many :skill_details, inverse_of: :skill, order: "user_id, skill_id, dimension_id"
  has_many :users, through: :skill_details, uniq: true, order: "users.email"
  has_many :dimensions, through: :skill_details, uniq: true, order: "dimensions.sort_order"

  attr_accessible :code, :label, :description, :parent, :sort_order

  SEED_VALUES = [
    { code: "html", label: "HTML", description: "Hypertext Markup Language", sort_order: 100},
    { code: "html5", parent: "html", label: "HTML5", description: "Modern HTML", sort_order: 200},
    { code: "canvas", parent: "html5", label: "<canvas>", description: "The 2D/3D graphics element in HTML5", sort_order: 300},
    { code: "css", label: "CSS", description: "Cascading Style Sheets", sort_order: 400},
    { code: "sass", parent: "css", label: "SASS", description: "Syntactically Awesome Style Sheets", sort_order: 500},
    { code: "scss", parent: "css", label: "SCSS", description: nil, sort_order: 600},
    { code: "js", label: "Javascript", description: "Scripting language", sort_order: 700},
    { code: "jquery", parent: "js", label: "jQuery", description: "Ubiquitous Javascript framework/toolkit", sort_order: 800},
    { code: "jqueryui", parent: "jquery", label: "jQuery UI", description: "Widgets for built on top of jQuery", sort_order: 900}
  ]

  def self.seed(overwrite = false)
    SEED_VALUES.each do |item|
      record = find_or_create_by_code item[:code], item
      record.update_attributes! item if overwrite
    end
  end

end