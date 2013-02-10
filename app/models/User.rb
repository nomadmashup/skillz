class User < ActiveRecord::Base

  has_many :skill_details, inverse_of: :user, order: "user_id, skill_id, dimension_id"
  has_many :skills, through: :skill_details, uniq: true, order: "skills.sort_order"
  has_many :dimensions, through: :skill_details, uniq: true, order: "dimensions.sort_order"

  attr_accessible :email, :first_name, :last_name, :project

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.seed(overwrite = false)

    path = Rails.root.join('db','seeds','users.yml')
    File.open(path) do |file|
      YAML.load_documents(file) do |doc|
        doc.keys.each do |key|
          attributes = doc[key].merge(email: key)
          record = find_or_create_by_email key, attributes
          record.update_attributes! attributes if overwrite
        end
      end
    end

  end

end