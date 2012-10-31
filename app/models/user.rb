class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  # Devise is the gem for User and Log in stuff
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :omniauthable, :authentication_keys => [:login]

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, 
                  :password_confirmation, :remember_me,
                  :provider, :uid, :login, :image, :page, :sex
  
  has_many :events_users
  has_many :events, through: :events_users

  # creates a new user after facebook said that everything is ok
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.info
    more_data = access_token.extra.raw_info
    if user = User.find_by_email(data.email)
      if data.image.present?    # update the user's image every time he logs in
        user.update_attribute(:image, data.image)
      end
      if more_data.link.present?
        user.update_attribute(:page, more_data.link)
      end
      user
    else # Create a user with a stub password. 
      User.create!(email: data.email, password: Devise.friendly_token[0,20], 
                   username: data.name, image: data.image, page: more_data.link,
                   sex: more_data.gender)
    end
  end

  # creates a new user after gmail said that everything is ok
  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    if user = User.find_by_email(data.email)
      if data.image.present?    # update the user's image every time he logs in
        user.update_attribute(:image, data.image)
      end
      user
    else # Create a user with a stub password. 
      User.create!(:email => data.email, :password => Devise.friendly_token[0,20], 
                   :username => data.name, image: data.image)
    end
  end

  # Needed for Logging in by either username or email. Don't know what this does exactly
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

end

