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

    $("button").addClass "disabled"
    $("a").click (e)->
      $(this).css "pointer", "default"
      e.preventDefault();

    nav = $(this).parents(".navbar")
    person = $("#skillz_person").val()

    nav.find(".btn-user .person strong").text person
    nav.find(".btn-user .person").attr "title", "Loading skills for " + person

    nav.find(".btn-user .dropdown-toggle span").removeClass("caret").text "Changing..."
    nav.find(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "Loading skills for " + person

    window.toggleUserForm()

  $(".btn-user .self_user a").click (e)->

    $("button").addClass "disabled"
    $("a").click (e)->
      $(this).css "pointer", "default"
      e.preventDefault();

    nav = $(this).parents(".navbar")
    person = nav.find(".btn-user .person strong").text()

    nav.find(".btn-user .self_user a").attr "title", "Updating " + person

    nav.find(".btn-user .dropdown-toggle span").removeClass("caret").text "Updating..."
    nav.find(".btn-user .dropdown-toggle").addClass("disabled").attr "title", "Updating " + person

  $(".btn-user .go_self a").click (e)->

    $("button").addClass "disabled"
    $("a").click (e)->
      $(this).css "pointer", "default"
      e.preventDefault();

    nav = $(this).parents(".navbar")
    person = nav.find(".btn-user .go_self small").text().substr("Go to ".length)

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

parameterize = (value)->
  value.toLowerCase().replace(" ", "_").replace("'", "")

window.showTree
window.toggleUserForm = ->
  form = $ "#skillz_person_form"
  nav = form.parents(".navbar")
  nav.toggleClass "edit"
  form.find("input").focus() if nav.hasClass "edit"

window.resetDimension = (skill, dimension)->
  button = $ ".btn.btn-#{parameterize(skill)}.btn-#{parameterize(dimension)}"
  button.removeClass().addClass "btn btn-small dropdown-toggle #{parameterize(skill)} #{parameterize(dimension)}"
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
  button.removeClass().addClass "btn btn-small dropdown-toggle #{className} btn-#{parameterize(skill)} btn-#{parameterize(dimension)}"
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