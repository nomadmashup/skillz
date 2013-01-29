require 'csv'

class Skill < ActiveRecord::Base

  has_many :skill_details, inverse_of: :skill, order: "user_id, skill_id, dimension_id"
  has_many :users, through: :skill_details, uniq: true, order: "users.email"
  has_many :dimensions, through: :skill_details, uniq: true, order: "dimensions.sort_order"

  attr_accessible :code, :label, :description, :parent, :sort_order

  TOP_PARENT_CODE = "top"

  def self.seed(overwrite = false)
    path = Rails.root.join('db','seeds','skillz.csv')
    CSV.parse(File.read(path), headers: true) do |row|
      next if TOP_PARENT_CODE == row["code"]
      attributes = {
        code: row["code"].present? ? row["code"].strip : nil,
        label: row["label"].present? ? row["label"].strip : nil,
        parent: row["parent"].present? ? row["parent"].strip : nil,
        description: row["description"].present? ? row["description"].strip : nil,
        sort_order: row["sort_order"].present? ? row["sort_order"].strip : nil
      }
      record = find_or_create_by_code attributes[:code], attributes
      record.update_attributes! attributes if overwrite
    end
  end

  def depth
    level = 0
    skill = self
    until TOP_PARENT_CODE == skill.parent do
      level += 1
      skill = Skill.find_by_code(skill.parent)
    end
    level
  end

  def top_parent
    parents.first.code rescue TOP_PARENT_CODE
  end

  def parents
    list = []
    skill = self
    until TOP_PARENT_CODE == skill.parent do
      skill = Skill.find_by_code(skill.parent)
      list.unshift(skill)
    end
    list
  end

end