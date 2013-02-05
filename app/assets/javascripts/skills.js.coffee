# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

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

  $("#skillz_person").typeahead
    source: ("#{user["first_name"]} #{user["last_name"]}" for user in window.skillzUsers)
    updater: window.changePerson
    minLength: 1

  $("#skills_search_value").typeahead
    source: (skill["label"] for skill in window.skills)
    updater: window.searchSkill
    minLength: 1

  $(".got_skillz a").click (e)->
    person = $(".btn-user .person strong").text()
    $(".btn-user .dropdown-toggle span").removeClass("caret").text "Reloading..."
    $(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "Reloading " + person
    disableActions()

  $("tr.skill_depth_1").show();

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

disableActions = ->
  window.scrollTo 0, 0
  $("a[data-target=\".nav-collapse\"]").addClass "hidden-phone"
  $("body .overlay").fadeIn 444.4 #ms
  $("body").css "overflow", "hidden"
  $(".btn.person, .btn.dropdown-toggle").css("cursor", "default").click (e)->
    e.preventDefault()

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
  el.effect "highlight", 1618.03399 #ms