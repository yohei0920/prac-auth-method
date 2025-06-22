require 'rails_helper'

RSpec.describe 'Api::V1::Health', type: :request do
  describe 'GET /api/v1/health' do
    context '認証なしの場合' do
      it '401 Unauthorizedを返す' do
        get '/api/v1/health'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '認証ありの場合' do
      before do
        @auth_headers = {
          'HTTP_AUTHORIZATION' => 'Basic ' + Base64.strict_encode64('admin:password')
        }
      end

      it 'messageパラメータなしで400 Bad Requestを返す' do
        get '/api/v1/health', headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('MISSING_PARAMETER')
        expect(json_response['error']['message']).to eq('message parameter is required')
        expect(json_response['error']['details']).to eq('Please provide a message parameter in your request')
        expect(json_response['error']['timestamp']).to be_present
        expect(json_response['error']['request_id']).to be_present
      end

      it 'messageパラメータありで200 OKを返す' do
        get '/api/v1/health?message=Hello World', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['status']).to eq('ok')
        expect(json_response['data']['message']).to eq('Hello World')
        expect(json_response['timestamp']).to be_present
        expect(json_response['request_id']).to be_present
      end

      it '空のmessageパラメータで400 Bad Requestを返す' do
        get '/api/v1/health?message=', headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('MISSING_PARAMETER')
      end
    end

    context '不正な認証情報の場合' do
      it '401 Unauthorizedを返す' do
        auth_headers = {
          'HTTP_AUTHORIZATION' => 'Basic ' + Base64.strict_encode64('wrong:credentials')
        }
        
        get '/api/v1/health', headers: auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/health' do
    context '認証なしの場合' do
      it '401 Unauthorizedを返す' do
        post '/api/v1/health'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '認証ありの場合' do
      before do
        @auth_headers = {
          'HTTP_AUTHORIZATION' => 'Basic ' + Base64.strict_encode64('admin:password'),
          'CONTENT_TYPE' => 'application/json'
        }
      end

      it 'JSONボディなしで400 Bad Requestを返す' do
        post '/api/v1/health', headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('MISSING_PARAMETER')
        expect(json_response['error']['message']).to eq('Required parameters missing')
      end

      it '不正なJSONで400 Bad Requestを返す' do
        post '/api/v1/health', 
             params: '{ invalid json }', 
             headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('INVALID_JSON')
        expect(json_response['error']['message']).to eq('Invalid JSON format in request body')
      end

      it '正しいJSONボディで200 OKを返す' do
        post '/api/v1/health', 
             params: { health: { data: 'test data' } }.to_json, 
             headers: @auth_headers
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['status']).to eq('created')
        expect(json_response['data']['data']).to eq('test data')
        expect(json_response['timestamp']).to be_present
        expect(json_response['request_id']).to be_present
      end

      it 'ネストしたJSONデータで200 OKを返す' do
        nested_data = {
          health: {
            data: 'complex data',
            settings: {
              enabled: true,
              timeout: 30,
              retry_count: 3
            },
            metadata: {
              version: '1.0.0',
              created_at: '2024-01-01T00:00:00Z',
              tags: ['api', 'test']
            },
            tags: ['important', 'urgent'],
            nested_data: [
              {
                name: 'item1',
                value: 100,
                sub_items: [
                  { id: 1, label: 'sub1' },
                  { id: 2, label: 'sub2' }
                ]
              }
            ]
          }
        }

        post '/api/v1/health', 
             params: nested_data.to_json, 
             headers: @auth_headers
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['status']).to eq('created')
        expect(json_response['data']['data']).to eq('complex data')
        expect(json_response['data']['settings']['enabled']).to eq(true)
        expect(json_response['data']['settings']['timeout']).to eq(30)
        expect(json_response['data']['metadata']['version']).to eq('1.0.0')
        expect(json_response['data']['tags']).to eq(['important', 'urgent'])
        expect(json_response['data']['nested_data'][0]['name']).to eq('item1')
        expect(json_response['data']['nested_data'][0]['sub_items'][0]['label']).to eq('sub1')
      end

      it 'JSON Schemaバリデーションエラーで400 Bad Requestを返す（timeoutが範囲外）' do
        invalid_data = {
          health: {
            data: 'test data',
            settings: {
              enabled: true,
              timeout: 150,  # 最大値100を超えている
              retry_count: 3
            }
          }
        }

        post '/api/v1/health', 
             params: invalid_data.to_json, 
             headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('SCHEMA_VALIDATION_ERROR')
        expect(json_response['error']['message']).to eq('JSON Schema validation failed')
        expect(json_response['error']['details']).to include('timeout')
      end

      it 'JSON Schemaバリデーションエラーで400 Bad Requestを返す（不正なversion形式）' do
        invalid_data = {
          health: {
            data: 'test data',
            metadata: {
              version: 'invalid-version',  # 正規表現パターンに合わない
              created_at: '2024-01-01T00:00:00Z'
            }
          }
        }

        post '/api/v1/health', 
             params: invalid_data.to_json, 
             headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('SCHEMA_VALIDATION_ERROR')
        expect(json_response['error']['message']).to eq('JSON Schema validation failed')
        expect(json_response['error']['details']).to include('version')
      end

      it 'JSON Schemaバリデーションエラーで400 Bad Requestを返す（不正なプロパティ）' do
        invalid_data = {
          health: {
            data: 'test data',
            settings: {
              enabled: true,
              timeout: 30,
              invalid_property: 'should not be allowed'  # 許可されていないプロパティ
            }
          }
        }

        post '/api/v1/health', 
             params: invalid_data.to_json, 
             headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('SCHEMA_VALIDATION_ERROR')
        expect(json_response['error']['message']).to eq('JSON Schema validation failed')
      end
    end
  end

  describe 'PUT /api/v1/health' do
    context '認証なしの場合' do
      it '401 Unauthorizedを返す' do
        put '/api/v1/health'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '認証ありの場合' do
      before do
        @auth_headers = {
          'HTTP_AUTHORIZATION' => 'Basic ' + Base64.strict_encode64('admin:password'),
          'CONTENT_TYPE' => 'application/json'
        }
      end

      it 'JSONボディなしで400 Bad Requestを返す' do
        put '/api/v1/health', headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('MISSING_PARAMETER')
      end

      it '不正なJSONで400 Bad Requestを返す' do
        put '/api/v1/health', 
            params: '{ invalid json }', 
            headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('INVALID_JSON')
      end

      it '正しいJSONボディで200 OKを返す' do
        put '/api/v1/health', 
            params: { health: { id: '123', data: 'updated data' } }.to_json, 
            headers: @auth_headers
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['status']).to eq('updated')
        expect(json_response['data']['id']).to eq('123')
        expect(json_response['data']['data']).to eq('updated data')
        expect(json_response['timestamp']).to be_present
        expect(json_response['request_id']).to be_present
      end

      it 'ネストしたJSONデータで200 OKを返す' do
        nested_data = {
          health: {
            id: '456',
            data: 'updated complex data',
            settings: {
              enabled: false,
              timeout: 60,
              retry_count: 5
            },
            metadata: {
              version: '2.0.0',
              created_at: '2024-01-02T00:00:00Z',
              tags: ['api', 'production']
            },
            tags: ['critical', 'monitoring'],
            nested_data: [
              {
                name: 'item2',
                value: 200,
                sub_items: [
                  { id: 3, label: 'sub3' },
                  { id: 4, label: 'sub4' }
                ]
              }
            ]
          }
        }

        put '/api/v1/health', 
            params: nested_data.to_json, 
            headers: @auth_headers
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['status']).to eq('updated')
        expect(json_response['data']['id']).to eq('456')
        expect(json_response['data']['data']).to eq('updated complex data')
        expect(json_response['data']['settings']['enabled']).to eq(false)
        expect(json_response['data']['settings']['timeout']).to eq(60)
        expect(json_response['data']['metadata']['version']).to eq('2.0.0')
        expect(json_response['data']['tags']).to eq(['critical', 'monitoring'])
        expect(json_response['data']['nested_data'][0]['name']).to eq('item2')
        expect(json_response['data']['nested_data'][0]['sub_items'][0]['label']).to eq('sub3')
      end

      it 'JSON Schemaバリデーションエラーで400 Bad Requestを返す（負の値）' do
        invalid_data = {
          health: {
            id: '123',
            data: 'test data',
            nested_data: [
              {
                name: 'item1',
                value: -10,  # 最小値0未満
                sub_items: [
                  { id: 1, label: 'sub1' }
                ]
              }
            ]
          }
        }

        put '/api/v1/health', 
            params: invalid_data.to_json, 
            headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('SCHEMA_VALIDATION_ERROR')
        expect(json_response['error']['message']).to eq('JSON Schema validation failed')
        expect(json_response['error']['details']).to include('value')
      end
    end
  end

  describe 'DELETE /api/v1/health' do
    context '認証なしの場合' do
      it '401 Unauthorizedを返す' do
        delete '/api/v1/health'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '認証ありの場合' do
      before do
        @auth_headers = {
          'HTTP_AUTHORIZATION' => 'Basic ' + Base64.strict_encode64('admin:password')
        }
      end

      it 'idパラメータなしで400 Bad Requestを返す' do
        delete '/api/v1/health', headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']['code']).to eq('MISSING_PARAMETER')
        expect(json_response['error']['message']).to eq('id parameter is required')
      end

      it 'idパラメータありで200 OKを返す' do
        delete '/api/v1/health', params: { id: '123' }, headers: @auth_headers
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['status']).to eq('deleted')
        expect(json_response['data']['id']).to eq('123')
        expect(json_response['timestamp']).to be_present
        expect(json_response['request_id']).to be_present
      end
    end
  end
end
