class Dimension < ActiveRecord::Base

  has_many :dimension_options, inverse_of: :dimension
  has_many :skill_details, inverse_of: :dimension, order: "user_id, skill_id, dimension_id"
  has_many :users, through: :skill_details, uniq: true, order: "users.email"
  has_many :skills, through: :skill_details, uniq: true, order: "skills.sort_order"

  attr_accessible :code, :label, :description, :sort_order

  def self.seed(overwrite = false)

    path = Rails.root.join('db','seeds','dimensions.yml')
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

end