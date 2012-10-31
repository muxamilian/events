module EventsHelper

  # This is useful for event.max_attendees to say that there is no limit
  def self.infinity 
    2147483647 # 2^31-1
  end

  def self.max_results 
    100
  end

  def mapify events
    events.to_gmaps4rails do |event, marker|
      marker.picture({
        picture: event.get_according_icon,
        width: 20,
        height: 34
      })
      marker.infowindow ''
      marker.title event.description
      marker.json({id: event.id})
    end
  end
  
  def get_datetime_or_nil date, time
    begin
      datetime = DateTime.strptime(date+' '+time,'%Y-%m-%d %H:%M')
      time = datetime.to_time
      time = Time.zone.local_to_utc time
      time.to_datetime
    rescue
      nil
    end
  end

  def get_integer_or_inf str
    begin
      Integer(str)      
    rescue
      EventsHelper.infinity
    end
  end

  def search_helper query, datetime, timeframe
    date = ''
    time = ''
    begin
      date = datetime.strftime '%Y-%m-%d'
      time = datetime.strftime '%H:%M'
      starttime = datetime - timeframe.hours
      endtime = datetime + timeframe.hours
      if query.empty?
        @events = Event
          .limit(EventsHelper.max_results)
          .where(datetime: starttime..endtime)
      else
        query.squish!
        @events = Event.limit(EventsHelper.max_results)
          .where(datetime: starttime..endtime)
          .full_search(query)
      end
    rescue
      @events = Array.new
    end
    {markers: @events, 
     query:   {search_query: query,
               date: date,
               time: time,
               timeframe: timeframe
              }
    }
  end

  def format_datetime datetime
    begin
      datetime.strftime '%Y-%m-%d %H:%M'
    rescue
      'datetime is invalid'
    end
  end

end
