module ErrorMessagesConcern
  extend ActiveSupport::Concern

  private

  # エラーメッセージ定数
  ERROR_MESSAGES = {
    missing_parameter: {
      code: 'MISSING_PARAMETER',
      message: '%{param_name} parameter is required',
      details: 'Please provide a %{param_name} parameter in your request'
    },
    
    missing_parameters_body: {
      code: 'MISSING_PARAMETER',
      message: 'Required parameters missing',
      details: 'Please provide the required parameters in the request body'
    },
    
    schema_validation: {
      code: 'SCHEMA_VALIDATION_ERROR',
      message: 'JSON Schema validation failed'
    },
    
    invalid_json: {
      code: 'INVALID_JSON',
      message: 'Invalid JSON format in request body',
      details: 'The request body contains malformed JSON. Please check your JSON syntax.'
    },
    
    parameter_missing: {
      code: 'MISSING_PARAMETER',
      message: 'Required parameter missing: %{param_name}',
      details: "The '%{param_name}' parameter is required but was not provided."
    },

    unauthorized: {
      code: 'UNAUTHORIZED',
      message: 'Authentication failed or token is invalid',
      details: 'You are not authorized to access this resource'
    },

    token_expired: {
      code: 'TOKEN_EXPIRED',
      message: 'Token has expired',
      details: 'Your authentication token has expired. Please login again to get a new token.'
    }
  }.freeze

  def get_error_message(key, **params)
    message_config = ERROR_MESSAGES[key]
    return nil unless message_config

    {
      code: message_config[:code],
      message: message_config[:message] % params,
      details: message_config[:details]&.then { |details| details % params }
    }
  end
end 