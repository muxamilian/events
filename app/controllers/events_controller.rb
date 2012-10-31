class EventsController < ApplicationController
  include EventsHelper
  # to escape javascript properly
  include ActionView::Helpers::JavaScriptHelper

  def index 
    @events = Array.new
    if params.has_key? :marker
      id = params[:marker]
      @events << Event.find(params[:marker])
    end
    result = {markers: Array.new, query: ''}
    datetime = get_datetime_or_nil params[:s_date], params[:s_time]
    if (params.has_key? :todo) && (params[:todo] == 'search')
      result = search_helper(params[:s_query], 
                             datetime,
                             Integer(params[:s_timeframe]))
    end
    @events = result[:markers] + @events
    @query = result[:query].to_json
    @empty = @events.empty?
    @events = mapify @events
    respond_to do |format|
      format.html # index.html.erb
      format.json {render json: @events}
      format.json {render json: @query}
    end
  end

  def create
    datetime = get_datetime_or_nil params[:c_date], params[:c_time]
    max_attendees = get_integer_or_inf(params[:c_max_attendees])
    event = {description: params[:c_description],
             address: params[:c_address],
             datetime: datetime,
             max_attendees: max_attendees}
    @event = Event.new(event)
    if user_signed_in? && @event.save
      current_user.events << @event
      @event.update_attribute :number_of_attendees, 1
      current_user.events_users.find_by_event_id(@event.id).update_attribute :owner, true
      @events = mapify @event
    else
      if !user_signed_in?
        @event.errors.add :user, 'is not signed in'
      end
    end
    @event.errors.add :datetime, 'is in wrong format' if !datetime
    respond_to do |format|
      format.js
      format.json {render json: @events}
    end
  end

  def add_tag
    @tag_is_blank = false
    tag_to_add = params[:t_tag]
    @event = Event.find(Integer params[:t_event_id])
    if tag_to_add.empty?
      @tag_is_blank = true
    else
      @event.tag_list << tag_to_add
      @event.save
      @rendered_new_tags = 
        render_to_string partial: 'tags', 
                         locals: {event: @event}
      @rendered_new_tags = escape_javascript @rendered_new_tags
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_tag
    @event = Event.find(params[:id])
    @event.tag_list.remove(params[:tag_name])
    @event.save
    @rendered_new_tags = 
      render_to_string partial: 'tags', 
                       locals: {event: @event}
    @rendered_new_tags = escape_javascript @rendered_new_tags
    respond_to do |format|
      format.js
    end
  end

  def update
    @event = Event.find(params[:id])
    @id = params[:id]
    datetime = get_datetime_or_nil params[:e_date], params[:e_time]
    max_attendees = get_integer_or_inf(params[:e_max_attendees])
    event = {description: params[:e_description],
             address: params[:e_address],
             datetime: datetime,
             max_attendees: max_attendees}
    if user_signed_in? && current_user.events_users.find_by_event_id(@event.id).owner
      @event.update_attributes(event)
    else
      if !user_signed_in?
        @event.errors.add :user, 'is not signed in'
      end
      if !current_user.events_users.find_by_event_id(@event.id).owner
        @event.errors.add :user, 'does not own this event'
      end      
    end
    @event.errors.add :datetime, 'is in wrong format' if !datetime
    @updated_event = mapify @event
    respond_to do |format|
      format.js
      format.json {render json: @updated_event}
    end
  end

  def local_events
    # all events within 0.5 degrees around the user's location are shown
    width_of_search_window = 0.5 # This are normal degrees
    offset = width_of_search_window / 2
    lat = Float params[:lat]
    lng = Float params[:lng]
    datetime = (Time.zone.local_to_utc(Time.zone.now)).to_datetime
    starttime = datetime - 30.minutes
    endtime = datetime + 24.hours
    southern_edge = lat - offset
    northern_edge = lat + offset
    western_edge = lng - offset
    eastern_edge = lng + offset
    now = 
    @events = Event
      .limit(EventsHelper.max_results)
      .where(lat: southern_edge..northern_edge,
             lng: western_edge..eastern_edge,
             datetime: starttime..endtime)
    @events = mapify @events
    respond_to do |format|
      format.json {render json: @events}
    end
  end

  def infowindow
    baseURI = request.host_with_port
    url_params = {marker: params[:id]}
    @perma_link = 'http://'+baseURI+'/?'+url_params.to_query
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html {render locals: {event: @event}, layout: false}
    end
  end

  def attend
    @errors = Array.new
    @event = Event.find(params[:id])
    @success = false
    if user_signed_in? && !(@event.users.include? current_user) && (@event.users.length < @event.max_attendees)
      @event.users << current_user
      @event.update_attribute :number_of_attendees, @event.number_of_attendees+1
      @success = true
    elsif !(@event.users.length < @event.max_attendees)
      @errors << 'This event is full...'
    else
      @errors << 'Something went wrong...'
    end
    respond_to do |format|
      format.js {render locals: {errors: @errors}}
    end
  end

  def unattend
    @errors = Array.new
    @event = Event.find(params[:id])
    @id = params[:id]
    if user_signed_in?
      @event.users.delete current_user
      @event.update_attribute :number_of_attendees, @event.number_of_attendees-1
      @success = true
    else
      @success = false
      @errors << 'Something went wrong...'
    end
    respond_to do |format|
      format.js
    end
  end

  def edit
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html {render layout: false}
    end
  end

  def all_events
    @events = current_user.events.order('datetime DESC')
    respond_to do |format|
      format.json {render json: (mapify @events)}
    end
  end
  def past_events
    @events = current_user.events.order('datetime DESC')
    @events.keep_if do |event|
      event.datetime < 30.minutes.ago
    end
    respond_to do |format|
      format.json {render json: (mapify @events)}
    end
  end
  def present_events
    @events = current_user.events.order('datetime DESC')
    @events.keep_if do |event|
      event.datetime >= 30.minutes.ago && event.datetime <= 30.minutes.from_now
    end
    respond_to do |format|
      format.json {render json: (mapify @events)}
    end
  end
  def future_events
    @events = current_user.events.order('datetime DESC')
    @events.keep_if do |event|
      event.datetime > 30.minutes.from_now
    end
    respond_to do |format|
      format.json {render json: (mapify @events)}
    end
  end

  def my_events
    @events = current_user.events.order('datetime DESC')
    @events_past = Array.new
    @events_present = Array.new
    @events_future = Array.new
    @events.each do |event|
      if event.datetime < 30.minutes.ago
        @events_past << event
      elsif event.datetime > 30.minutes.from_now
        @events_future << event
      else
        @events_present << event
      end
    end
    @events_past_json = mapify @events_past
    @events_present_json = mapify @events_present
    @events_future_json = mapify @events_future
    @events_json = mapify @events
    respond_to do |format|
      format.html {render layout: false}
      format.json {render json: @events_json}
      format.json {render json: @events_present_json}
      format.json {render json: @events_past_json}
      format.json {render json: @events_future_json}
    end
  end

  def add_owner
    event = Event.find(params[:id])
    user = User.find(params[:u_id])
    user.events_users.find_by_event_id(event.id).update_attribute :owner, true
    respond_to do |format|
      format.js
    end
  end

  def remove_owner
    event = Event.find(params[:id])
    user = User.find(params[:u_id])
    user.events_users.find_by_event_id(event.id).update_attribute :owner, false
    respond_to do |format|
      format.js
    end
  end

  def search
    @errors = Array.new
    @events = Array.new
    @query_string = ''
    datetime = get_datetime_or_nil params[:s_date], params[:s_time]
    if datetime
      begin
        timeframe = Integer(params[:s_timeframe])
      rescue
        timeframe = 0
        @errors << "Please enter the timeframe properly"
      end
      result = search_helper(params[:s_query], datetime, timeframe)
      @events = result[:markers]
      @query = result[:query].to_json
      params.delete(:action)
      params.delete(:controller)
      params.merge!({todo: 'search'})
      @query_string = '?'+params.to_query
    else
      @errors << 'Datetime is in wrong format'
    end
    @errors << "Please enter something to search for" if params[:s_query].empty? && !datetime
    @errors << "Didn't find anything" if @events.empty?
    @events = mapify @events
    respond_to do |format|
      format.js
      format.json {render json: @events}
      format.json {render json: @query}
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @id = params[:id]
    if current_user.events.include? @event
      @event.destroy
      @success = true
    else
      @success = false
    end
    respond_to do |format|
      format.js
    end
  end

end
