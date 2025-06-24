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

  private

  def extract_token
    request.headers['Authorization']&.split(' ')&.last
  end
end
