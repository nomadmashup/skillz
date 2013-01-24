module SkillsHelper

  def get_class_name(dimension_value)
    case dimension_value
      when "beginner"
        "btn-success"
      when "intermediate"
        "btn-primary"
      when "expert"
        "btn-inverse"
      when "learning_now"
        "btn-info"
      when "used_to_know"
        "btn-warning"
      when "current"
        "btn-inverse"
      when "more"
        "btn-success"
      when "less"
        "btn-danger"
      when "perfect"
        "btn-primary"
      when "love"
        "btn-success"
      when "hate"
        "btn-danger"
      when "learn"
        "btn-info"
      when "teach"
        "btn-success"
      when "organize"
        "btn-primary"
      else
        ""
    end
  end

end
