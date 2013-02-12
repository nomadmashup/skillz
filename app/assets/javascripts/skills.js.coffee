# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

KEY =
  ESC: 27

DELAY =
  small: 314.159 #ms
  medium: 618.03399 #ms
  large: 1618.03399 #ms

$ ->

  initializeBootstrap()
  initializeEvents()

  $("tr.skill_depth_1").show();

initializeBootstrap = ->

  $("#skillz_person").typeahead
    source: ("#{user["first_name"]} #{user["last_name"]}" for user in window.skillzUsers)
    updater: window.changePerson
    minLength: 1

  $("#skills_search_value").typeahead
    source: (skill["label"] for skill in window.skills)
    updater: window.searchSkill
    minLength: 1

  content = "<p>To tell the <strong>Skillz</strong> app who you are, use the person drop-down at the top of the page and browse to yourself, then use the drop-down <em>again</em> to indicate \"I'm me\"</p>"
  content += "<p><a href=\"javascript: window.changePersonNow();\">Show Me</a><a class=\"pull-right\" href=\"javascript: $('.actions .message i.icon-question-sign').popover('hide');\">Got It</a></p>"
  $(".actions .message i.icon-question-sign").popover
    html: true
    placement: "top"
    trigger: "manual"
    title: "Skillz Tip"
    content: content

  content = "<p>To tell the <strong>Skillz</strong> app who you are, use this drop-down to browse to yourself, then use this same drop-down <em>again</em> to indicate \"I'm me\"</p>"
  content += "<p><a href=\"javascript: window.dropdownPersonNow();\">Show Me</a><a class=\"pull-right\" href=\"javascript: $('.btn-user .dropdown-toggle').attr('data-toggle', 'dropdown').popover('hide');\">Got It</a></p>"
  $(".btn-user .dropdown-toggle").popover
    html: true
    placement: "bottom"
    trigger: "manual"
    title: "Skillz Tip"
    content: content

  content = "<p>Appeciate yourself.</p><p>You're awesome.</p><p><strong>Nomand Ninjas</strong> thanks you.</p><p>Click if you got <a href=\"javascript: alert('Oh yeah !!!'); $('p.copyright').popover('hide');\"><strong>Skillz</strong></a></p>"
  $("p.copyright").popover
    html: true
    placement: "top"
    trigger: "manual"
    title: "Skillz Tip"
    content: content

  content = "<p>Browse to yourself. Then after the page reloads, use this same dropdown menu <em>again</em> and choose \"I'm me\".<p>"
  content += "<p><a href=\"javascript: window.personFormNow();\">Show Me</a><a class=\"pull-right\" href=\"javascript: $('.btn-user .dropdown-toggle').attr('data-toggle', 'dropdown'); $('.btn-user li.change').popover('hide');\">Got It</a></p>"
  $(".btn-user li.change").popover
    html: true
    placement: "bottom"
    trigger: "manual"
    title: "Skillz Tip"
    content: content

initializeEvents = ->

  $('a[data-toggle="pill"]').on 'show', (e)->
    current = $(e.target).attr("data-target").substr 1, $(e.target).attr("data-target").length - 1
    window.setSkillCategory current, false

  $("#skillz_person_form button[type=cancel]").click (e)->
    window.toggleUserForm()
    e.preventDefault()

  $("#skillz_person_form button[type=submit]").click (e)->
    window.toggleUserForm()
    disableActions()
    nav = $(this).parents(".navbar")
    person = $("#skillz_person").val()
    nav.find(".btn-user .person strong").text person
    nav.find(".btn-user .person").attr "title", "Loading skills for " + person
    nav.find(".btn-user .dropdown-toggle span").removeClass("caret").text "Changing..."
    nav.find(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "Loading skills for " + person

  $(".btn-user .self_user a, .btn-user a.btn.person").not(".no_current").click (e)->
    disableActions()
    nav = $(this).parents(".navbar")
    person = nav.find(".btn-user .person strong").text()
    nav.find(".btn-user .self_user a").attr "title", "Updating " + person
    action = if $(this).hasClass("person") then "Reloading" else "Updating"
    nav.find(".btn-user .dropdown-toggle span").removeClass("caret").text "#{action}..."
    nav.find(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "#{action} #{person}"

  $("a.toggle_form").click (e)->
    window.toggleUserForm()
    e.preventDefault()

  $(".btn-user .go_self a").click (e)->
    disableActions()
    nav = $(this).parents(".navbar")
    person = nav.find(".btn-user .go_self small").text().replace("  (you)", "").substr("Go to ".length)
    nav.find(".btn-user .person strong").text person
    nav.find(".btn-user .self_user a").attr "title", "Loading skills for " + person
    nav.find(".btn-user .dropdown-toggle span").removeClass("caret").text "Changing..."
    nav.find(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "Loading skills for " + person

  $(".skill_label").click ->
    row = $(this).parents "tr"
    if row.hasClass "collapsed"
      row.removeClass "collapsed"
      rows = $ "tr." + $(this).find(".icon-plus").attr("data-target")
      rows.show()
      rows.filter(".collapsed").each ->
        $("tr." + $(this).find(".icon-minus").attr("data-target")).hide()
    else
      row.addClass "collapsed"
      $("tr." + $(this).find(".icon-minus").attr("data-target")).hide()

  $(".skills_toggle .skills_expand").click (e)->
    $(".skills_table tr").removeClass("collapsed").show()
    e.preventDefault()

  $(".skills_toggle .skills_collapse").click (e)->
    $(".skills_table tr").addClass("collapsed").not(".skill_depth_1").hide()
    e.preventDefault()

  $("form.skills_search").submit (e)->
    e.preventDefault()
    window.searchSkill $(this).find("input").val()

  $(".got_skillz a").click (e)->
    person = $(".btn-user .person strong").text()
    $(".btn-user .dropdown-toggle span").removeClass("caret").text "Reloading..."
    $(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "Reloading " + person
    disableActions()

  $("#skillz_comment_form textarea").focus (e)->
    showComment()

  $("#skillz_comment_form").keyup (e)->
    if KEY.ESC == e.which
      $("#skillz_comment_form textarea").blur() if cancelComment()

  $("#skillz_comment_form button[type=cancel]").click (e)->
    cancelComment()
    e.preventDefault()

  toggleCommentPopover = (message)->
    target = message.find "i.icon-question-sign"
    popover = message.find ".popover"
    if popover.hasClass "in"
      target.popover "hide"
      textarea = $("#skillz_comment_form textarea")
      window.scrollTo 0, textarea.position().top - 10
    else
      target.popover "show"
      popover = $ ".actions .message .popover.in"
      window.scrollTo popover.position().left, popover.position().top - 10

  $(".actions .message").click ->
    toggleCommentPopover $(this)

  $("body").keyup (e)->
    if KEY.ESC == e.which
      $(".actions .message i.icon-question-sign").popover "hide"
      $(".btn-user .dropdown-toggle").popover "hide"
      $(".btn-user li.change").popover "hide"
      $("p.copyright").popover

  $("p.copyright span").click ->
      $("p.copyright").popover "show"

showComment = ->
  $("#skillz_comment_form textarea").attr "rows", 3
  $("#skillz_comment_form .actions").show()
  $("#skillz_comment_form").animate {opacity: "1.0"}, DELAY.small
  $("ul.faq.hidden-phone").removeClass "affix"
  window.scrollTo 0, $("#skillz_comment_form").position().top

hideComment = ->
  $(".actions .message i.icon-question-sign").popover "hide"
  $("#skillz_comment_form textarea").val("").attr "rows", 1
  $("#skillz_comment_form .actions").hide()
  $("#skillz_comment_form").css {opacity: "0.61803399"}
  $("ul.faq.hidden-phone").addClass "affix"

cancelComment = ->
  userConfirmed = true
  userConfirmed = confirm("You will lose whatever you've written so far. Are you sure?") unless "" == $("#skillz_comment_form textarea").val()
  if userConfirmed then hideComment() else $("#skillz_comment_form textarea").focus()
  userConfirmed

disableActions = ->
  window.scrollTo 0, 0
  $("a[data-target=\".nav-collapse\"]").addClass "hidden-phone"
  $("body .overlay").fadeIn DELAY.medium
  $("body").css "overflow", "hidden"
  $(".btn.person, .btn.dropdown-toggle").css("cursor", "default").click (e)->
    e.preventDefault()

parameterize = (value)->
  value.toLowerCase().replace(" ", "_").replace("'", "")

window.toggleUserForm = ->
  form = $ "#skillz_person_form"
  nav = form.parents(".navbar")
  nav.toggleClass "edit"
  if nav.hasClass "edit"
    $("a[data-target=\".nav-collapse\"]").addClass "hidden-phone"
    form.find("input").focus()
  else
    $("a[data-target=\".nav-collapse\"]").removeClass "hidden-phone"
  false

window.resetDimension = (skill, dimension)->
  button = $ ".btn.btn-#{parameterize(skill)}.btn-#{parameterize(dimension)}"
  button.attr "class", "btn btn-mini dropdown-toggle btn-#{parameterize(skill)} btn-#{parameterize(dimension)}"
  button.find(".current").html dimension
  button.attr "title", "Click to choose"
  listItems = button.parents(".btn-group").find "ul li"
  listItems.show()
  listItems.slice(listItems.length - 2, listItems.length).each ->
    $(this).hide()
  url = "/save?u=#{skillzUser}&s=#{skill}&d=#{dimension}"
  $.ajax
      url: url

window.setDimension = (skill, dimension, value, className, tooltip)=>
  button = $ ".btn.btn-#{parameterize(skill)}.btn-#{parameterize(dimension)}"
  button.attr "class", "btn btn-mini dropdown-toggle #{className} btn-#{parameterize(skill)} btn-#{parameterize(dimension)}"
  button.find(".current").html value
  button.attr "title", tooltip
  listItems = button.parents(".btn-group").find ".dropdown-menu li"
  listItems.show()
  listItems.each ->
    anchor = $(this).find("a")
    $(this).hide() if anchor.length > 0 && anchor.attr("href").indexOf(value) >= 0
  url = "/save?u=#{skillzUser}&s=#{skill}&d=#{dimension}&v=#{value}"
  $.ajax
    url: url

window.setSkillCategory = (category, show = true)->

  $("#skillz_comment_form input[name=c]").val category

  prev_category = null
  next_category = null

  found = false
  $("a[data-toggle=pill]").each ->
    current = $(this).attr("data-target").substr 1, $(this).attr("data-target").length - 1
    if current == category
      found = true
      $(this).tab "show" if show
    else
      if found
        next_category = current if null == next_category
      else
        prev_category = current

  if prev_category
    $(".pager .previous").removeClass("disabled").find("a").attr "href", "javascript: window.setSkillCategory('#{prev_category}');"
  else
    $(".pager .previous").addClass "disabled"

  if next_category
    $(".pager .next").removeClass("disabled").find("a").attr "href", "javascript: window.setSkillCategory('#{next_category}');"
  else
    $(".pager .next").addClass "disabled"

  window.scrollTo 0, 0

window.searchSkill = (item)->
  $("#skills_search_value").val item
  skill = (skill for skill in window.skills when skill["label"].toLowerCase() == item.toLowerCase())
  if skill.length > 0
    if skill[0]["parents"] == "null"
      window.setSkillCategory skill[0]["code"]
      window.highlight $("ul.nav a[data-target=##{skill[0]["code"]}]")
    else
      $("tr").addClass("collapsed").hide()
      $("tr.skill_depth_1").show()
      parents = JSON.parse skill[0]["parents"]
      window.setSkillCategory parents[0]
      subParents = parents.slice 1
      ($("i.icon-plus[data-target=#{parent}]").click() for parent in subParents)
      row = $("i.icon-plus[data-target=" + skill[0]["code"] + "]").parents("tr td")
      rowTop = row.position().top
      window.scrollTo 0, rowTop - $(window).height() / 2 + row.height() / 2 if rowTop
      window.highlight row
  else
    alert "No '#{item}' for you!"
  item

window.changePerson = (item)->
  $("#skillz_person_form input").val item
  $("#skillz_person_form button[type=submit]").click()
  item

window.highlight = (el)->
  el.effect "highlight", DELAY.large

window.changePersonNow = ->
  window.toggleUserForm() if $(".navbar").hasClass "edit"
  dropdown = $ ".btn-user .dropdown-toggle"
  dropdown.popover("show").delay(DELAY.small).effect
    effect: 'pulsate'
    duration: DELAY.medium
  $(".btn-user .popover").one "click", ->
    $(".btn-user .dropdown-toggle").popover "hide"
  dropdown.removeAttr "data-toggle"
  dropdown.one "click", ->
    $(this).popover "hide"
    $(this).attr "data-toggle", "dropdown"
    $(this).dropdown "toggle"
  window.scrollTo $(".btn-user .popover").position().left, 0

window.dropdownPersonNow = ->
  dropdown = $ ".btn-user .dropdown-toggle"
  dropdown.dropdown "toggle"
  $(".btn-user li.change").popover("show").delay(DELAY.medium).effect
    effect: "shake"
    distance: 5
    times: 5
    duration: DELAY.medium
  popover = $ ".btn-user ul.dropdown-menu .popover"
  popover.one "click", ->
    $(".btn-user .dropdown-toggle").popover "hide"
  window.scrollTo popover.position().left, 0

window.personFormNow = ->
  $(".btn-user li.change").popover "hide"
  $("#skillz_person").attr "placeholder", "Enter your own name"
  window.toggleUserForm()

window.commentNow = ->
  showComment()
  $("#skillz_comment").focus()
