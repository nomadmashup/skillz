class DimensionOption < ActiveRecord::Base

  belongs_to :dimension, inverse_of: :dimension_options

  attr_accessible :dimension_id, :short_label, :long_label, :description, :sort_order, :value

  SEED_VALUES = [
    { dimension: "level", value: "beginner", short_label: "Beginner", long_label: "Beginner", description: nil, sort_order: 100},
    { dimension: "level", value: "intermediate", short_label: "Intermediate", long_label: "Intermediate", description: nil, sort_order: 200},
    { dimension: "level", value: "expert", short_label: "Expert", long_label: "Expert", description: nil, sort_order: 300},
    { dimension: "status", value: "learning", short_label: "Learning Now", long_label: "Learning Now", description: nil, sort_order: 100},
    { dimension: "status", value: "used_to_know", short_label: "Used To Know", long_label: "Used To Know", description: nil, sort_order: 200},
    { dimension: "satisfaction", value: "more", short_label: "More", long_label: "I want to do more of this", description: nil, sort_order: 100},
    { dimension: "satisfaction", value: "less", short_label: "Less", long_label: "I want to do less of this", description: nil, sort_order: 200},
    { dimension: "passion", value: "love", short_label: "Love", long_label: "I love this", description: nil, sort_order: 100},
    { dimension: "passion", value: "hate", short_label: "Hate", long_label: "I hate this", description: nil, sort_order: 200},
    { dimension: "synergy", value: "learn", short_label: "Learn", long_label: "I want to learn this", description: nil, sort_order: 100},
    { dimension: "synergy", value: "teach", short_label: "Teach", long_label: "I can teach this", description: nil, sort_order: 200}
  ]

  def self.seed(overwrite = false)
    SEED_VALUES.each do |item|
      dimension = Dimension.find_by_code(item[:dimension])
      attributes = item.reject{|k,v| k == :dimension}
      record = dimension.dimension_options.find_or_create_by_value item[:value], attributes
      record.update_attributes! attributes if overwrite
    end
  end

end