class SkillsController < ApplicationController

  before_filter :authenticate
  before_filter :set_user, except: :save

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "con" && password == "bestboss"
    end
  end

  def set_user
    email = cookies.permanent[:current_user] = params[:u] || cookies[:current_user]
    @current_user = User.find_by_email(email)
    @self_user = User.find_by_email(cookies[:self_user])
    redirect_to controller: controller_name, action: action_name if params[:u].present?
  end

  def change

    new_person = User.find_by_first_name params[:q]
    new_person = User.find_by_last_name params[:q] if new_person.blank?
    new_person = User.find_by_email params[:q] if new_person.blank?
    if new_person.blank?
      matches = User.all.select{|u| "#{u.first_name} #{u.last_name}" == params[:q]}
      new_person = matches.first if matches.size > 0
    end

    cookies.permanent[:self_user] = params[:s] if params.has_key?(:s)

    if new_person.present?
      redirect_to root_path(u: new_person.email)
    else
      flash[:error] = "'#{params[:q]}' was not found"
      redirect_to root_path
    end

  end

  def index
    options = DimensionOption.joins(:dimension).order("dimensions.sort_order, dimension_options.sort_order").group_by{|option| option.dimension.label}
    skills = Skill.order(:sort_order).all
    @row_info = skills.map do |skill|
      {
        skill: skill,
        skill_details: @current_user.present? ? @current_user.skill_details(true) : nil,
        dimension_options: options,
        parent: ( skills.select{|s| s.parent == skill.code}.size > 0)
      }
    end.group_by{|r| r[:skill].top_parent}
  end

  def save
    result = { status: "unknown" }
    begin
      dimension = Dimension.find_by_label(params[:d])
      attributes = {
        user: User.find_by_email(params[:u]),
        skill: Skill.find_by_code(params[:s]),
        dimension: dimension
      }
      attributes[:value] = params[:v].present? ? dimension.dimension_options.find_by_short_label(params[:v]).short_label : nil
      raise "missing or invalid parameters" if attributes[:user].blank? || attributes[:skill].blank? || attributes[:dimension].blank? || (params[:v].present? && attributes[:value].blank?)
      query = SkillDetail.where(user_id: attributes[:user].id, skill_id: attributes[:skill].id, dimension_id: attributes[:dimension].id)
      if attributes[:value].present?
        if 0 == query.count
          SkillDetail.create! attributes
          result[:status] = "created"
        else
          query.first.update_attributes attributes
          result[:status] = "updated"
        end
      else
        query.delete_all
        result[:status] = "deleted"
      end
    rescue Exception => ex
      result = { status: "error", exception: ex.inspect }
    end
    render json: result
  end

end
