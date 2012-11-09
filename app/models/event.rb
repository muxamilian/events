class Event < ActiveRecord::Base
  include PgSearch
  pg_search_scope :full_search, 
    against: {
      description: 'A', 
      address: 'B', 
      normalized_address: 'B'
    },
    associated_against: {
      tags: [:name]    
    }

  validates :description, :datetime, :address, :max_attendees, :presence => true
  
  attr_accessible :description, :datetime, :address, :normalized_address, :max_attendees
  
  # Tell gmaps4rails how to handle locations
  acts_as_gmappable :lat => :lat, :lng => :lng, :process_geocoding => true, :validation => true,
                    :address => :address, :normalized_address => :normalized_address,
                    :check_process => false,
                    :msg => "is invalid, couldn't figure out the coordinates of your address..."

  has_many :events_users
  has_many :users, through: :events_users

  acts_as_taggable_on :tags

  # Returns if the address should be translated to Latitude and Longitude (lat and lng)
  def geocode?
    (!address.blank? && (lat.blank? || lng.blank?)) || address_changed?
  end

  # These are logically constants, however,
  # writing them capitalized looks ugly
  def get_according_color
    if self.datetime < 30.minutes.ago
      Event.color_past
    elsif self.datetime > 30.minutes.from_now
      Event.color_future
    else
      Event.color_present
    end
  end

  def get_according_icon
    if self.datetime < 30.minutes.ago
      '/assets/markers/brown_Marker.png'
    elsif self.datetime > 30.minutes.from_now
      '/assets/markers/paleblue_Marker.png'
    else
      '/assets/markers/red_Marker.png'
    end
  end

  def self.searchable_language
    'english'
  end

  def self.color_past 
    '#cb9d7c'
  end
  def self.color_present
    '#ff776b'
  end
  def self.color_future
    '#bce3ff'
  end

end

