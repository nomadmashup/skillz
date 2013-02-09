require 'csv'

class SkillsController < ApplicationController

  before_filter :authenticate
  before_filter :set_user, except: :save

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "con" && password == "bestboss"
    end unless Rails.env.development?
  end

  def set_user
    flash[:info] = nil
    email = cookies.permanent[:current_user] = params[:u] || cookies[:current_user]
    @current_user = User.find_by_email(email)
    @self_user = User.find_by_email(cookies[:self_user])
    redirect_to controller: controller_name, action: action_name if params[:u].present?
  end

  def change

    new_person = User.find_by_first_name params[:q].titleize
    new_person = User.find_by_last_name params[:q].titleize if new_person.blank?
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
    skills = Skill.order(:sort_order).all
    skill_details = @current_user.skill_details(true) rescue []
    dimension_options = DimensionOption.joins(:dimension).select("dimensions.id, dimensions.label, dimensions.sort_order, dimension_options.short_label, dimension_options.long_label").order("dimensions.sort_order, dimension_options.sort_order").group_by{|option| option[:label]}
    @row_info = skills.map do |skill|
      {
        skill: skill,
        skill_details: skill_details,
        dimension_options: dimension_options,
        parent: ( skills.select{|s| s.parent == skill.code}.size > 0)
      }
    end.group_by{|r| r[:skill].top_parent}
    flash[:info] = "You are viewing the list of skills. Choose a person above to browse their skills." if @current_user.blank?
    flash[:info] = "You are viewing answers that you or other team members have given. To edit your own skills, use the drop-down above and browse to yourself, then use the drop-down again to indicate \"I'm me\"" if @current_user.present? && @self_user.blank?
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

  def csv
    csv_file = "tmp/skillz.csv"
    CSV.open(csv_file, 'w') do |writer|
      writer << %w{ Person Skill Dimension Value }
      SkillDetail.select("users.email as person, skills.label as skill, dimensions.label as dimension, value").joins([:user, :skill, :dimension]).all.each do |detail|
        writer << [
          detail[:person],
          detail[:skill],
          detail[:dimension],
          detail[:value]
        ]
      end
    end
    send_file csv_file
  rescue Exception => ex
    Rails.logger.debug "skills#csv:  #{ex.inspect}"
    flash[:error] = "No CSV for you!!!"
    redirect_to root_path
  end


  def faq

    @questions = [
      { section: "who", question: "Who wrote this?", answer: "Programmed with care by <strong>james.trask@hp.com</strong>".html_safe },
      { question: "Who came up with all the skills?", answer: "William Hertling and James Bradford Trask ideated most of the skills in a cool 30 minutes. The James took it the rest of the way as the web application was developed. From now on the skills reflect feedback from everyone in our Awesome Software Section."},
      { question: "Who can enter skills?", answer: "Anyone in our Awesome Software Section" },
      { question: "Who thought this was necessary?", answer: "Con and Bill asked the James to look into this." },
      { question: "Who is sponsoring this?", answer: "Con, the leader of our Awesome Software Section" },
      { question: "Who let the dogs out?", answer: "Who? Who? Who?" },
      { question: "Who fills this stuff out?", answer: "Everyone in our Awesome Software Section" },
      { question: "Who do you want to be today?", answer: "Do you wanna be just like someone on TV?" },
      { question: "Who has the same interests as I do?", answer: "Reports coming soon. You'll be able to slice and dice to your heart's content." },
      { question: "What software versions does this site use?", answer: "Ruby 1.9.3, Rails 2.3.11, twitter-bootstrap-rails 2.2.0" },
      { section: "what", question: "What information can other people see?", answer: "People in the section can see all your answers. Nobody else can." },
      { question: "What is a skill?", answer: "Anything useful to you, somebody else, a group of people, or an organization." },
      { question: "What is a dimension?", answer: "A dimension is one particular aspect of a skill, a particular way of assessing a skill, or a type of opinion one may have about a skill. Examples: Skill Level, Status, Satisfaction, etc." },
      { question: "What reports are available?", answer: "The only output currently supported is a <strong>CSV</strong> export. More reports coming soon.".html_safe },
      { question: "What do the colors mean?", answer: "Nothing specific. The colors are chosen for their emotional impact and their eye-popping pizzazz." },
      { question: "What devices can I use to view and edit my skills?", answer: "Any device you can imagine." },
      { section: "where", question: "Where is the data stored?", answer: "Heroku"},
      { question: "Where is the site hosted?", answer: "Heroku"},
      { question: "Where is the source code repository?", answer: "GitHub"},
      { question: "Where can I find help?", answer: "Email thread(s)"},
      { question: "Where can I find skill matches?", answer: "The best way to find synergies is to examine the CSV."},
      { question: "Where are the wild things?", answer: "Not sure yet. Looking into it..."},
      { question: "Where did you get my email address?", answer: "You work in our section. The HP directory has your info."},
      { section: "when", question: "When are my answers saved?", answer: "The moment you answer the question." },
      { question: "When do others see my answers?", answer: "The next time they view your skills." },
      { question: "When can I change my answers?", answer: "Right now." },
      { question: "When did this project start?", answer: "Two weeks ago." },
      { question: "When is this project going live?", answer: "One week from now."},
      { question: "When can I start entering information?", answer: "Now. But information may be cleared." },
      { section: "why", question: "Why are you asking me for this information?", answer: "You are a valued team member."},
      { question: "Why should I care?", answer: "Because we care about you. You want to be all that you can be."},
      { question: "Why is this helpful to the section?", answer: "Skills equal abilities. Abilities equal value prop."},
      { question: "Why you cannot just use Excel?", answer: "Too cumbersome. Bad Mac experience."},
      { question: "Why there are no user accounts?", answer: "Too cumbersome."},
      { question: "Why I cannot import my LinkedIn skills list?", answer: "You will be able to soon. Full integration."},
      { question: "Why is it so easy to use?", answer: "Because a ton of thought and care went into it."},
      { question: "Why do you seem to know me?", answer: "Because you are me. We are all me."},
      { section: "how", question: "How the heck did you put all this together?", answer: "With much meticulous care."},
      { question: "How is data pulled back out of the system?", answer: "Currently, only CSV export is supported."},
      { question: "How do I know you are not selling my information?", answer: "You just have to trust us. We are all in this together."},
      { question: "How do I get involved?", answer: "You already are. Vocalize."},
      { question: "How do I sign in?", answer: "No need."},
      { question: "How does the site respond so beautifully to different device dimensions?", answer: "Design aforethought."},
      { question: "How did you know my name?", answer: "You work in our section. We looked you up in the HP directory."}
    ]

  end

end
