class Skill < ActiveRecord::Base

  has_many :skill_details, inverse_of: :skill, order: "user_id, skill_id, dimension_id"
  has_many :users, through: :skill_details, uniq: true, order: "users.email"
  has_many :dimensions, through: :skill_details, uniq: true, order: "dimensions.sort_order"

  attr_accessible :code, :label, :description, :parent, :sort_order

  def self.seed(overwrite = false)

    path = Rails.root.join('db','seeds','skills.yml')
    File.open(path) do |file|
      YAML.load_documents(file) do |doc|
        doc.keys.each do |key|
          attributes = doc[key].merge(code: key)
          record = find_or_create_by_code key, attributes
          record.update_attributes! attributes if overwrite
        end
      end
    end

  end

  def depth
    level = 0
    skill = self
    until skill.parent.blank? do
      level += 1
      skill = Skill.find_by_code(skill.parent)
    end
    level
  end

  def top_parent
    parent = nil
    skill = self
    until skill.parent.blank? do
      parent = skill.parent
      skill = Skill.find_by_code(skill.parent)
    end
    parent
  end

end