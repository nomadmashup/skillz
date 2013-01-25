# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('a[data-toggle="pill"]').on 'show', (e)->
    current = $(e.target).attr("data-target").substr 1, $(e.target).attr("data-target").length - 1
    window.setSkillCategory current, false

parameterize = (value)->
  value.toLowerCase().replace(" ", "_").replace("'", "")

window.resetDimension = (skill, dimension)->
  button = $ ".btn.#{parameterize(skill)}.#{parameterize(dimension)}"
  button.removeClass().addClass "btn dropdown-toggle #{parameterize(skill)} #{parameterize(dimension)}"
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
  button = $ ".btn.#{parameterize(skill)}.#{parameterize(dimension)}"
  button.removeClass().addClass "btn dropdown-toggle #{className} #{parameterize(skill)} #{parameterize(dimension)}"
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