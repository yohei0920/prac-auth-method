module BasicAuthConcern
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  private

  def basic_authenticate
    authenticate_with_http_basic do |username, password|
      username == basic_auth_username && password == basic_auth_password
    end || request_http_basic_authentication
  end

  def basic_auth_username
    ENV.fetch('BASIC_AUTH_USERNAME', Rails.application.credentials.basic_auth&.dig(:username) || 'admin')
  end

  def basic_auth_password
    ENV.fetch('BASIC_AUTH_PASSWORD', Rails.application.credentials.basic_auth&.dig(:password) || 'password')
  end
end 