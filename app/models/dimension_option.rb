class DimensionOption < ActiveRecord::Base

  belongs_to :dimension, inverse_of: :dimension_options

  attr_accessible :dimension_id, :short_label, :long_label, :description, :sort_order, :value

  def self.seed(overwrite = false)

    path = Rails.root.join('db','seeds','dimension_options.yml')
    File.open(path) do |file|
      YAML.load_documents(file) do |doc|
        doc.keys.each do |key|
          dimension = Dimension.find_by_code(doc[key]["dimension"])
          attributes = doc[key].reject{|k| k.to_s == "dimension"}.merge(value: key)
          record = dimension.dimension_options.find_or_create_by_value key, attributes
          record.update_attributes! attributes if overwrite
        end
      end
    end

  end

end