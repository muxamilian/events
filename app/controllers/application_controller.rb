class ApplicationController < ActionController::Base
  protect_from_forgery  # Specifies that the csrf-token is needed when forms are posted to the server
end
