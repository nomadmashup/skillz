class SkillsController < ApplicationController

  def index

    options = DimensionOption.joins(:dimension).order("dimensions.sort_order, dimension_options.sort_order").group_by{|option| option.dimension.label}

    @row_info = Skill.order(:sort_order).all.map do |skill|
      {
        skill: skill,
        skill_details: "abc",
        dimension_options: options
      }
    end.group_by{|r| r[:skill].top_parent}

    @current_user = User.all.shuffle.first

  end

end
