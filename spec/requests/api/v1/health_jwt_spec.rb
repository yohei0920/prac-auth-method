require 'rails_helper'

RSpec.describe "API Health JWT認証", type: :request do
  let!(:user) { User.create!(email: "test@example.com", name: "Test User") }

  describe "GET /api/v1/health" do
    context "有効なJWTトークンを送信した場合" do
      let(:valid_token) do
        # 有効なJWTトークンを生成（実装後に修正）
        "valid.jwt.token"
      end

      it "認証されて200が返る" do
        get "/api/v1/health", 
            params: { message: "hello" }, 
            headers: { "Authorization" => "Bearer #{valid_token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["user"]).to eq("Test User")
        expect(json_response["data"]["message"]).to eq("hello")
      end
    end

    context "無効なJWTトークンを送信した場合" do
      it "401エラーになる" do
        get "/api/v1/health", 
            params: { message: "hello" }, 
            headers: { "Authorization" => "Bearer invalid.jwt.token" }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]["code"]).to eq("UNAUTHORIZED")
      end
    end

    context "JWTトークンがない場合" do
      it "401エラーになる" do
        get "/api/v1/health", params: { message: "hello" }
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]["code"]).to eq("UNAUTHORIZED")
      end
    end

    context "Authorizationヘッダーの形式が間違っている場合" do
      it "401エラーになる" do
        get "/api/v1/health", 
            params: { message: "hello" }, 
            headers: { "Authorization" => "Basic invalid" }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/health" do
    let(:valid_params) do
      {
        health: {
          message: "test message",
          data: "test data"
        }
      }
    end

    context "有効なJWTトークンを送信した場合" do
      let(:valid_token) do
        # 有効なJWTトークンを生成（実装後に修正）
        "valid.jwt.token"
      end

      it "認証されて200が返る" do
        post "/api/v1/health", 
             params: valid_params.to_json, 
             headers: { 
               "Authorization" => "Bearer #{valid_token}",
               "Content-Type" => "application/json"
             }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["status"]).to eq("created")
      end
    end

    context "無効なJWTトークンを送信した場合" do
      it "401エラーになる" do
        post "/api/v1/health", 
             params: valid_params.to_json, 
             headers: { 
               "Authorization" => "Bearer invalid.jwt.token",
               "Content-Type" => "application/json"
             }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/health" do
    context "有効なJWTトークンを送信した場合" do
      let(:valid_token) do
        # 有効なJWTトークンを生成（実装後に修正）
        "valid.jwt.token"
      end

      it "認証されて200が返る" do
        delete "/api/v1/health", 
               params: { id: "123" }, 
               headers: { "Authorization" => "Bearer #{valid_token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["status"]).to eq("deleted")
      end
    end

    context "無効なJWTトークンを送信した場合" do
      it "401エラーになる" do
        delete "/api/v1/health", 
               params: { id: "123" }, 
               headers: { "Authorization" => "Bearer invalid.jwt.token" }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 