module ApiResponseConcern
  extend ActiveSupport::Concern
  include ErrorMessagesConcern

  included do
    rescue_from JSON::ParserError, with: :handle_json_parse_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  end

  private

  def render_success(data, status: :ok)
    render json: {
      success: true,
      data: data,
      timestamp: Time.current.iso8601,
      request_id: request.request_id
    }, status: status
  end

  def render_error(code:, message:, details: nil, status: :bad_request)
    error_response = {
      success: false,
      error: {
        code: code,
        message: message,
        timestamp: Time.current.iso8601,
        request_id: request.request_id
      }
    }

    error_response[:error][:details] = details if details.present?

    render json: error_response, status: status
  end

  def handle_json_parse_error(exception)
    error_config = get_error_message(:invalid_json)
    render_error(**error_config, status: :bad_request)
  end

  def handle_parameter_missing(exception)
    error_config = get_error_message(:parameter_missing, param_name: exception.param)
    render_error(**error_config, status: :bad_request)
  end
end 