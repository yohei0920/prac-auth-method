module TokenAuthConcern
  extend ActiveSupport::Concern
  include ErrorMessagesConcern

  included do
    before_action :authenticate_user_from_token!
  end

  private

  def authenticate_user_from_token!
    auth_header = request.headers['Authorization']
    # Bearerなし
    unless auth_header&.start_with?('Bearer ')
      error_config = get_error_message(:unauthorized)
      return render json: {
        success: false,
        error: {
          code: error_config[:code],
          message: error_config[:message],
          timestamp: Time.current.iso8601,
          request_id: request.request_id
        }
      }, status: :unauthorized
    end

    token = auth_header.split(' ', 2).last
    # Tokenなし
    if token.blank?
      error_config = get_error_message(:unauthorized)
      return render json: {
        success: false,
        error: {
          code: error_config[:code],
          message: error_config[:message],
          timestamp: Time.current.iso8601,
          request_id: request.request_id
        }
      }, status: :unauthorized
    end

    @current_user = User.find_by(api_token: token)
    # ユーザーが見つからない
    unless @current_user
      error_config = get_error_message(:unauthorized)
      render json: {
        success: false,
        error: {
          code: error_config[:code],
          message: error_config[:message],
          timestamp: Time.current.iso8601,
          request_id: request.request_id
        }
      }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end 