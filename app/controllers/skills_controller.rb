require 'csv'

class SkillsController < ApplicationController

  include ActionView::Helpers::DateHelper

  before_filter :authenticate
  before_filter :set_user, except: [:save, :save_comment]

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
    flash[:info] = "<p>You are viewing the list of skills. Choose a person above to browse their skills.&nbsp;&nbsp;&nbsp;<a href=\"javascript: $('.alert').alert('close'); window.changePersonNow();\">Show Me</a></p>".html_safe if @current_user.blank?
    flash[:info] = "<p>You are viewing answers that you or other team members have given. To edit your own skills, use the drop-down above and browse to yourself, then use the drop-down again to indicate \"I'm me\".&nbsp;&nbsp;&nbsp;<a href=\"javascript: $('.alert').alert('close'); window.changePersonNow();\">Show Me</a></p>".html_safe if @current_user.present? && @self_user.blank?
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

  def comments
    @comments = Comment.joins("LEFT OUTER JOIN users on users.id = comments.user_id").select("users.first_name, users.last_name, comments.text, comments.created_at").order("comments.created_at desc").all
  end

  def save_comment
    Comment.create! user_id: params[:u], text: params[:t], action: params[:a], category: params[:c]
    flash[:success] = "<p>You comment was saved.</p><p>View <a href=\"#{comments_path}\">comments</a></p>".html_safe
    redirect_to action: params[:a]
  end

  def faq

    @questions = [
      { section: "who", question: "Who wrote this?", answer: "Programmed with care by <strong>james.trask@hp.com</strong>".html_safe },
      { question: "Who came up with all the skills?", answer: "William Hertling and James Bradford Trask ideated most of the skills in a cool 30 minutes. The James took it the rest of the way as the web application was developed. Nowadays the skills reflect feedback from everyone in our awesome software section. <a href=\"javascript: window.commentNow();\" title=\"Suggest a skill\">Comment</a> below to suggest a skill.".html_safe },
      { question: "Who can enter skills?", answer: "Anyone in our awesome software section" },
      { question: "Who thought this was necessary?", answer: "Con and Bill asked the James to look into this." },
      { question: "Who is sponsoring this?", answer: "Con, the leader of our awesome software section" },
      { question: "Who let the dogs out?", answer: "Who? Who? Who?" },
      { question: "Who fills this stuff out?", answer: "Everyone in our awesome software section" },
      { question: "Who has the same interests as I do?", answer: "Reports are coming soon. You'll be able to use these super duper reports to slice and dice to your heart's content. In the meantime, use the #{render_to_string partial: "skills/csv_download"}.".html_safe },
      { section: "what", question: "What software does this site use?", answer: "The site uses <strong>Ruby</strong> <span class=\"muted\"><small>(1.9.3)</small></span> on <strong>Rails</strong> <span class=\"muted\"><small>(2.3.11)</small></span> with Twitter's <a href=\"http://twitter.github.com/bootstrap/\" target=\"_blank\">Bootstrap</a> framework as the CSS/JS foundation.".html_safe },
      { question: "What information can other people see?", answer: "People in our awesome software section can see all of your answers. Nobody else can. Nobody can see your email address, although anyone can look it up easily in the HP directory." },
      { question: "What is a skill?", answer: "Anything useful to you, somebody else, a group of people, or an organization." },
      { question: "What is a dimension?", answer: "A dimension is one particular way of talking about, thinking about, or measuring a skill. Examples:  Skill Level (\"I am an expert on this\"), Status (\"I am up to date on this\"), Satisfaction (\"I want to do more of this\"), Passion (\"I love this\"), etc."},
      { question: "What reports are available?", answer: "The only output currently supported is a #{render_to_string partial: "skills/csv_download"} export. Download this file and open in Excel to slice and dice all you like. More reports coming soon.".html_safe },
      { question: "What do the colors mean?", answer: "Nothing specific, but important nonetheless. The colors are chosen for their emotional impact and their eye-popping pizzazz. They bring visual order to the results." },
      { question: "What devices can I use to view and edit my skills?", answer: "Any device you can imagine." },
      { section: "where", question: "Where is the site hosted?", answer: "Heroku"},
      { question: "Where is the data stored?", answer: "Heroku"},
      { question: "Where is the source code repository?", answer: "GitHub"},
      { question: "Where can I find help?", answer: "Currently, the best help and information is contained in emails sent by the James. Talking to the James is also a good bet."},
      { question: "Where can I find skill matches?", answer: "Until reports come out, the best way to find synergies is to examine the #{render_to_string partial: "skills/csv_download"}. Download and open the file in Excel and look for people with skills and desires that interest you.".html_safe},
      { question: "Where are the wild things?", answer: "Not sure yet. On an island if I recall. Looking into it..."},
      { question: "Where did you get my email address?", answer: "You work in our section. The HP directory has your info."},
      { section: "when", question: "When are my answers saved?", answer: "The moment you answer the question. Sometimes a little before, depending on how strong <em>The Force</em> is with you.".html_safe },
      { question: "When do others see my answers?", answer: "The next time they view your skills." },
      { question: "When can I change my answers?", answer: "Right <a href=\"#{@self_user.present? ? root_path(u: @self_user.email) : root_path}\" title=\"Synergize\">now</a>".html_safe },
      { question: "When did this project start?", answer: "Sunday January 20th, 2013 (about #{distance_of_time_in_words_to_now(Time.zone.parse("2013-01-20"))} ago)" },
      { question: "When is this project going live?", answer: "Wednesday February 13th, 2013 (about #{distance_of_time_in_words_to_now(Time.zone.parse("2013-02-13"))} ago)"},
      { question: "When can I start entering information?", answer: "You can enter information right now as part of the beta testing. But all your answers will be cleared before the initial public release." },
      { section: "why", question: "Why are you asking me for this information?", answer: "You are a valued team member. We like you. You have mad skillz. What you know and, more importantly, what you care about is valuable information to both to you and the world."},
      { question: "Why should I care?", answer: "Because we care about you. You want to be all that you can be. We want that too."},
      { question: "Why is this helpful to the section?", answer: "Skills equal abilities. Abilities equal value prop. Value prop equals the shizzle with upper management. HP win."},
      { question: "Why can't you just use Excel?".html_safe, answer: "Too cumbersome. Bad Mac experience. Extremely difficult to collect, assemble and organize data from 50-60 people."},
      { question: "Why are there no user accounts?", answer: "Too cumbersome. More work than this project affords. Lot's of maintenance involved. World is shifting to Google/FB identity providers."},
      { question: "Why can't I import my LinkedIn skills list?".html_safe, answer: "You will be able to soon. Full integration. Always."},
      { question: "Why is it so easy to use?", answer: "Because a ton of thought and care went into it. Subtle details define usability."},
      { question: "Why do you seem to know me?", answer: "Because you are me. We are all us. And we are you, and me. Software unites."},
      { section: "how", question: "How the heck did you put all this together?", answer: "With much meticulous care, no girlfriend, no kids, and no house."},
      { question: "How is data pulled back out of the system?", answer: "Currently, only #{render_to_string partial: "skills/csv_download"} export is supported. The #{render_to_string partial: "skills/csv_download"} format imports directly into Excel.".html_safe},
      { question: "How do I know you are not selling my information?", answer: "You just have to trust us. We are all in this together."},
      { question: "How do I get involved?", answer: "You already are. Vocalize."},
      { question: "How do I sign in?", answer: "No need. Sign in is for ecosystems where entities don't trust each other.".html_safe},
      { question: "How much does this site cost HP?", answer: "Nothing."},
      { question: "How does the site respond so beautifully to different device dimensions?", answer: "Design aforethought. Pure and simple."},
      { question: "How did you know my name?", answer: "You work in our section. We looked you up in the HP directory."},
      { question: "How long did the project take from first code to first release?", answer: "about #{distance_of_time_in_words_to_now(Time.zone.parse("2013-01-20"), Time.zone.parse("2013-02-13"))}"}
    ]

  end

end
