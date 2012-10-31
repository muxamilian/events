# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

infowindow = null

$ ->
  if google?
    infowindow = new google.maps.InfoWindow()
    Gmaps.map.geolocationFailure = (browser_support) ->
      alert "Geolocation didn't work. Some features won't work now. Have fun anyway ;D"

    Gmaps.map.callback = ->
      listenerify_markers()

    Gmaps.map.geolocationSuccess = ->
      if Gmaps.map.markers.length == 0
        load_local_events()

  set_date_and_time('#c_date', '#c_time')
  $('#c_date').datepicker({format: 'yyyy-mm-dd'});
  $('#c_time').timepicker showMeridian: false

  set_date_and_time('#s_date', '#s_time')
  $('#s_date').datepicker({format: 'yyyy-mm-dd'});
  $('#s_time').timepicker showMeridian: false

  $('.index-alert-container').css('width', $('#maps-overlay').css('width'))

  $("body").on "hidden", ".modal", ->
    $(this).removeData "modal"

  window.onpopstate = (e) ->
    if e.state
      replaceHelper(e.state.markers)
      set_search_form(e.state.query)

  Temporal.detect 'conchulio'



# When called with an id as argument, this function deletes the corresponding event via ajax
delete_event = (id) ->
  $.ajax
    url: "/events/"+id
    dataType: "script"
    type: "delete"

attend_event = (id) ->
  $.ajax
    url: "/events/"+id+"/attend"
    dataType: "script"
    type: "post"

unattend_event = (id) ->
  $.ajax
    url: "/events/"+id+"/attend"
    dataType: "script"
    type: "delete"

add_owner = (e_id, u_id) ->
  $.ajax
    url: "/events/"+e_id+"/owner"
    data: {u_id: u_id}
    dataType: "script"
    type: "post"

remove_owner = (e_id, u_id) ->
  $.ajax
    url: "/events/"+e_id+"/owner"
    data: {u_id: u_id}
    dataType: "script"
    type: "delete"

close_infowindow = ->
  infowindow.close()

reverse_geocode = (lat, lng, out, err, type) ->
  type = 'exact' if typeof (type) is "undefined"
  geocoder = new google.maps.Geocoder()
  latlng = new google.maps.LatLng(lat, lng)
  geocoder.geocode {'latLng': latlng}, (results, status) ->
    if(status == google.maps.GeocoderStatus.OK && results[0])
      if(type == 'exact')
        $(out).val(results[0].formatted_address)
      else
        $(out).val(results[1].formatted_address)
      $(err).hide(300)
    else
      $(err).html("<ul><li>Sorry, I couldn't get your location...</li></ul>")
      $(err).show(300)

delete_marker = (id) ->
  for marker in Gmaps.map.markers
    if marker.id == id
      Gmaps.map.clearMarker(marker)

all_events = ->
  $.ajax
    url: "events/all_events"
    dataType: 'json'
    success: (data) ->
      replaceHelper(data)
past_events = ->
  $.ajax
    url: "events/past_events"
    dataType: 'json'
    success: (data) ->
      replaceHelper(data)
present_events = ->
  $.ajax
    url: "events/present_events"
    dataType: 'json'
    success: (data) ->
      replaceHelper(data)
future_events = ->
  $.ajax
    url: "events/future_events"
    dataType: 'json'
    success: (data) ->
      replaceHelper(data)

show_perma_link = ->
  $(".button-container").hide 300
  $(".perma-link-button").hide 300
  $(".perma-link-text").show(300).focus()
hide_perma_link = ->
  $(".perma-link-text").hide 300
  $(".button-container").show 300
  $(".perma-link-button").show 300



bootstrap_alert = ->

bootstrap_alert.info = (message) ->
  $("#alert-container").prepend "<div class=\"fade in alert alert-info\"><a class=\"close\" data-dismiss=\"alert\">×</a><span>" + message + "</span></div>"

bootstrap_alert.warning = (message) ->
  $("#alert-container").prepend "<div class=\"fade in alert alert-warning\"><a class=\"close\" data-dismiss=\"alert\">×</a><span>" + message + "</span></div>"

bootstrap_alert.error = (message) ->
  $("#alert-container").prepend "<div class=\"fade in alert alert-error\"><a class=\"close\" data-dismiss=\"alert\">×</a><span>" + message + "</span></div>"

window.bootstrap_alert = bootstrap_alert



replaceHelper = (events) ->
  Gmaps.map.replaceMarkers events
  listenerify_markers()

addHelper = (events) ->
  Gmaps.map.addMarkers events
  listenerify_markers()

load_content = (marker) ->
  $.ajax
    url: '/events/'+marker.id+'/infowindow'
    success: (data) ->
      infowindow.close()
      infowindow.setContent(data)
      infowindow.open Gmaps.map.serviceObject, marker.serviceObject
      FB.XFBML.parse(document.getElementById('map'))

listenerify_markers = ->
  for marker in Gmaps.map.markers
    ((marker) ->
      google.maps.event.addListener marker.serviceObject, "click", ->
        load_content marker) (marker)

set_search_form = (query) ->
  if !(query == '')
    $('#s_query').val(query.search_query)
    $('#s_date').val(query.date)
    $('#s_time').val(query.time)
    $('#s_timeframe').val(query.timeframe)
    $('#search-errors').hide(300)

set_date_and_time = (date_widget, time_widget) ->
  now = new Date()
  $(date_widget).val(now.getFullYear()+'-'+(now.getMonth()+1)+'-'+now.getDate())
  $(time_widget).val(now.getHours()+':'+now.getMinutes())

load_local_events = (lat, lng) ->
  $.ajax
    url: "events/local_events"
    dataType: 'json'
    data: 
      lat: Gmaps.map.userLocation.lat()
      lng: Gmaps.map.userLocation.lng()
    success: (data) ->
      replaceHelper(data)
      if data.length > 0
        bootstrap_alert.info("Showing some local events")

remove_tag = (e_id, tag_name) -> 
  $.ajax
    url: "events/"+e_id+"/tag"
    type: 'delete'
    dataType: 'script'
    data:
      tag_name: tag_name



window.delete_event = delete_event
window.attend_event = attend_event
window.unattend_event = unattend_event
window.add_owner = add_owner
window.remove_owner = remove_owner
window.close_infowindow = close_infowindow
window.reverse_geocode = reverse_geocode
window.delete_marker = delete_marker
window.all_events = all_events
window.past_events = past_events
window.present_events = present_events
window.future_events = future_events
window.show_perma_link = show_perma_link
window.hide_perma_link = hide_perma_link
window.replaceHelper = replaceHelper
window.addHelper = addHelper
window.listenerify_markers = listenerify_markers
window.set_search_form = set_search_form
window.set_date_and_time = set_date_and_time
window.load_local_events = load_local_events
window.remove_tag = remove_tag

