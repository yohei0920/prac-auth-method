class Api::V1::AuthController < ApplicationController
  include ApiResponseConcern
  include ErrorMessagesConcern

  # トークン生成（ログイン）
  def login
    unless params[:email].present?
      error_config = get_error_message(:missing_parameter, param_name: 'email')
      return render_error(**error_config, status: :bad_request)
    end

    user = User.find_by(email: params[:email])
    
    if user
      # 実際のアプリではパスワード認証も必要ですが、今回は簡略化
      render json: {
        token: user.api_token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name
        }
      }
    else
      error_config = get_error_message(:unauthorized)
      render_error(**error_config, status: :unauthorized)
    end
  end

  # トークン再生成
  def refresh
    user = User.find_by(api_token: extract_token)
    
    if user
      user.regenerate_api_token
      render json: {
        token: user.api_token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name
        }
      }
    else
      error_config = get_error_message(:unauthorized)
      render_error(**error_config, status: :unauthorized)
    end
  end

  # ログアウト（トークン無効化）
  def logout
    user = User.find_by(api_token: extract_token)
    
    if user
      user.regenerate_api_token # 新しいトークンを生成して古いトークンを無効化
      render json: { message: 'Logged out successfully' }
    else
      error_config = get_error_message(:unauthorized)
      render_error(**error_config, status: :unauthorized)
    end
  end

  # JWT認証 - ログイン
  def jwt_login
    unless params[:email].present?
      error_config = get_error_message(:missing_parameter, param_name: 'email')
      return render_error(**error_config, status: :bad_request)
    end

    user = User.find_by(email: params[:email])
    
    if user
      # 本物のJWTトークンを生成
      token = generate_jwt_token(user)
      expires_in = 1.hour.to_i
      
      render json: {
        token: token,
        token_type: "Bearer",
        expires_in: expires_in,
        user: {
          id: user.id,
          email: user.email,
          name: user.name
        }
      }
    else
      error_config = get_error_message(:unauthorized)
      render_error(**error_config, status: :unauthorized)
    end
  end

  # JWT認証 - トークン再生成
  def jwt_refresh
    # JWTトークンの検証
    user = authenticate_jwt_token
    return unless user

    # 新しいJWTトークンを生成
    token = generate_jwt_token(user)
    expires_in = 1.hour.to_i
    
    render json: {
      token: token,
      token_type: "Bearer",
      expires_in: expires_in,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    }
  end

  # JWT認証 - ログアウト
  def jwt_logout
    # JWTトークンの検証
    user = authenticate_jwt_token
    return unless user

    # ログアウト成功メッセージを返す
    render json: { message: 'Logged out successfully' }
  end

  private

  def extract_token
    request.headers['Authorization']&.split(' ')&.last
  end

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: 1.hour.from_now.to_i  # 1時間後に有効期限切れ
    }
    
    JWT.encode(payload, jwt_secret_key, 'HS256')
  end

  def authenticate_jwt_token
    token = extract_token
    unless token.present?
      render_unauthorized
      return nil
    end

    begin
      decoded_token = JWT.decode(token, jwt_secret_key, true, { algorithm: 'HS256' })
      payload = decoded_token[0]
      user_id = payload['user_id']
      user = User.find(user_id)
      return user
    rescue JWT::ExpiredSignature
      error_config = get_error_message(:token_expired)
      render_error(**error_config, status: :unauthorized)
      return nil
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render_unauthorized
      return nil
    end
  end

  def render_unauthorized
    error_config = get_error_message(:unauthorized)
    render_error(**error_config, status: :unauthorized)
    return
  end

  def jwt_secret_key
    Rails.application.credentials.secret_key_base
  end
end
