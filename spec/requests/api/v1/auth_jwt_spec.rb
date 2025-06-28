require 'rails_helper'

RSpec.describe "API JWT認証エンドポイント", type: :request do
  let!(:user) { User.create!(email: "test@example.com", name: "Test User") }

  describe "POST /api/v1/auth/jwt_login" do
    context "存在するユーザーのemailを送信した場合" do
      it "JWTトークンとユーザー情報が返る" do
        post "/api/v1/auth/jwt_login", 
             params: { email: "test@example.com" }.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        
        expect(json_response["token"]).to be_present
        expect(json_response["token_type"]).to eq("Bearer")
        expect(json_response["expires_in"]).to be_present
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["user"]["email"]).to eq("test@example.com")
        expect(json_response["user"]["name"]).to eq("Test User")
      end

      it "トークンに有効期限が含まれる" do
        post "/api/v1/auth/jwt_login", 
             params: { email: "test@example.com" }.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        
        # トークンをデコードして有効期限を確認
        token = json_response["token"]
        decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' })
        payload = decoded_token[0]
        
        expect(payload["exp"]).to be_present
        expect(payload["exp"]).to be > Time.current.to_i
        expect(payload["user_id"]).to eq(user.id)
      end
    end

    context "存在しないユーザーのemailを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/auth/jwt_login", 
             params: { email: "nonexistent@example.com" }.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]["code"]).to eq("UNAUTHORIZED")
      end
    end

    context "emailパラメータがない場合" do
      it "400エラーになる" do
        post "/api/v1/auth/jwt_login", 
             params: {}.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "POST /api/v1/auth/jwt_refresh" do
    let(:valid_token) do
      # 有効なJWTトークンを生成
      payload = {
        user_id: user.id,
        email: user.email,
        exp: 1.hour.from_now.to_i
      }
      JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    end

    context "有効なJWTトークンを送信した場合" do
      it "新しいJWTトークンが返る" do
        post "/api/v1/auth/jwt_refresh", 
             headers: { "Authorization" => "Bearer #{valid_token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        
        expect(json_response["token"]).to be_present
        expect(json_response["token_type"]).to eq("Bearer")
        expect(json_response["expires_in"]).to be_present
        expect(json_response["user"]["id"]).to eq(user.id)
      end
    end

    context "有効期限切れのJWTトークンを送信した場合" do
      it "401エラーになる" do
        # 有効期限切れのトークンを生成
        expired_payload = {
          user_id: user.id,
          exp: 1.hour.ago.to_i  # 1時間前に有効期限切れ
        }
        expired_token = JWT.encode(expired_payload, Rails.application.credentials.secret_key_base, 'HS256')
        
        post "/api/v1/auth/jwt_refresh", 
             headers: { "Authorization" => "Bearer #{expired_token}" }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]["code"]).to eq("TOKEN_EXPIRED")
      end
    end

    context "無効なJWTトークンを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/auth/jwt_refresh", 
             headers: { "Authorization" => "Bearer invalid.token" }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "トークンがない場合" do
      it "401エラーになる" do
        post "/api/v1/auth/jwt_refresh"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/auth/jwt_logout" do
    let(:valid_token) do
      # 有効なJWTトークンを生成
      payload = {
        user_id: user.id,
        email: user.email,
        exp: 1.hour.from_now.to_i
      }
      JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    end

    context "有効なJWTトークンを送信した場合" do
      it "ログアウト成功メッセージが返る" do
        post "/api/v1/auth/jwt_logout", 
             headers: { "Authorization" => "Bearer #{valid_token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Logged out successfully")
      end
    end

    context "無効なJWTトークンを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/auth/jwt_logout", 
             headers: { "Authorization" => "Bearer invalid.token" }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 