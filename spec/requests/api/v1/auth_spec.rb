require 'rails_helper'

RSpec.describe "API認証エンドポイント", type: :request do
  let!(:user) { User.create!(email: "test@example.com", name: "Test User") }

  describe "POST /api/v1/auth/login" do
    context "存在するユーザーのemailを送信した場合" do
      it "トークンとユーザー情報が返る" do
        post "/api/v1/auth/login", 
             params: { email: "test@example.com" }.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        
        expect(json_response["token"]).to be_present
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["user"]["email"]).to eq("test@example.com")
        expect(json_response["user"]["name"]).to eq("Test User")
      end
    end

    context "存在しないユーザーのemailを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/auth/login", 
             params: { email: "nonexistent@example.com" }.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]["code"]).to eq("UNAUTHORIZED")
      end
    end

    context "emailパラメータがない場合" do
      it "400エラーになる" do
        post "/api/v1/auth/login", 
             params: {}.to_json, 
             headers: { "Content-Type" => "application/json" }
        
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "POST /api/v1/auth/refresh" do
    context "正しいトークンを送信した場合" do
      it "新しいトークンが返る" do
        old_token = user.api_token
        
        post "/api/v1/auth/refresh", 
             headers: { "Authorization" => "Bearer #{old_token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        
        expect(json_response["token"]).to be_present
        expect(json_response["token"]).not_to eq(old_token)
        expect(json_response["user"]["id"]).to eq(user.id)
        
        # 古いトークンが無効化されていることを確認
        user.reload
        expect(user.api_token).to eq(json_response["token"])
      end
    end

    context "間違ったトークンを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/auth/refresh", 
             headers: { "Authorization" => "Bearer wrongtoken" }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "トークンがない場合" do
      it "401エラーになる" do
        post "/api/v1/auth/refresh"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/auth/logout" do
    context "正しいトークンを送信した場合" do
      it "ログアウト成功メッセージが返る" do
        old_token = user.api_token
        
        post "/api/v1/auth/logout", 
             headers: { "Authorization" => "Bearer #{old_token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Logged out successfully")
        
        # トークンが無効化されていることを確認
        user.reload
        expect(user.api_token).not_to eq(old_token)
      end
    end

    context "間違ったトークンを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/auth/logout", 
             headers: { "Authorization" => "Bearer wrongtoken" }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "トークンがない場合" do
      it "401エラーになる" do
        post "/api/v1/auth/logout"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "トークンの一意性" do
    it "各ユーザーが異なるトークンを持つ" do
      user2 = User.create!(email: "test2@example.com", name: "Test User 2")
      
      expect(user.api_token).not_to eq(user2.api_token)
    end

    it "トークン再生成で新しいトークンが生成される" do
      old_token = user.api_token
      user.regenerate_api_token
      
      expect(user.api_token).not_to eq(old_token)
      expect(user.api_token).to be_present
    end
  end
end
