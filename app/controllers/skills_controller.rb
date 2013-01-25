class SkillsController < ApplicationController

  before_filter do
    puts "SKILLZ BEFORE #{action_name}"
    email = cookies[:current_user] = params[:u] || cookies[:current_user] || User.all.shuffle.first.email || "james.trask@hp.com"
    @current_user = User.find_by_email(email)
    puts "SKILLZ USER:  #{email}"
  end

  after_filter do
    puts "SKILLZ AFTER #{action_name}"
  end

  def index

    options = DimensionOption.joins(:dimension).order("dimensions.sort_order, dimension_options.sort_order").group_by{|option| option.dimension.label}

    @row_info = Skill.order(:sort_order).all.map do |skill|
      {
        skill: skill,
        skill_details: "abc",
        dimension_options: options
      }
    end.group_by{|r| r[:skill].top_parent}

  end

end
