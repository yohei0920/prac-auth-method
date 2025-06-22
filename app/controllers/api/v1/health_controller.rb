module Api
  module V1
    class HealthController < ApplicationController
      include BasicAuthConcern
      include ApiResponseConcern
      include JsonSchemaConcern
      before_action :basic_authenticate

      def index
        unless params[:message].present?
          render_error(
            code: 'MISSING_PARAMETER',
            message: 'message parameter is required',
            details: 'Please provide a message parameter in your request',
            status: :bad_request
          )
          return
        end
        
        render_success({
          status: 'ok',
          message: params[:message]
        })
      end

      def create
        # JSONボディからパラメータを取得
        data_params = health_params
        return if data_params.empty? # エラーが発生した場合は早期リターン
        
        render_success({
          status: 'created',
          message: 'POST request received',
          data: data_params[:data],
          settings: data_params[:settings],
          metadata: data_params[:metadata],
          tags: data_params[:tags],
          nested_data: data_params[:nested_data]
        })
      end

      def update
        # JSONボディからパラメータを取得
        data_params = health_params
        return if data_params.empty? # エラーが発生した場合は早期リターン
        
        render_success({
          status: 'updated',
          message: 'PUT request received',
          id: data_params[:id],
          data: data_params[:data],
          settings: data_params[:settings],
          metadata: data_params[:metadata],
          tags: data_params[:tags],
          nested_data: data_params[:nested_data]
        })
      end

      def destroy
        unless params[:id].present?
          render_error(
            code: 'MISSING_PARAMETER',
            message: 'id parameter is required',
            details: 'Please provide an id parameter to specify what to delete',
            status: :bad_request
          )
          return
        end

        render_success({
          status: 'deleted',
          message: 'DELETE request received',
          id: params[:id]
        })
      end

      private

      def health_params
        # ネストしたデータ構造を許可
        permitted_params = params.require(:health).permit(
          :id, 
          :data, 
          :message,
          # ネストしたオブジェクトの許可
          settings: [:enabled, :timeout, :retry_count],
          metadata: [:version, :created_at, :tags],
          # 配列の許可
          tags: [],
          # ネストした配列の許可
          nested_data: [:name, :value, sub_items: [:id, :label]]
        )
        
        # JSON Schemaバリデーション（パラメータ取得後に実行）
        return permitted_params if validate_json_schema(params.to_unsafe_h, health_schema)
        
        {}
      rescue ActionController::ParameterMissing => e
        # パラメータが不足している場合は適切なエラーを返す
        render_error(
          code: 'MISSING_PARAMETER',
          message: 'Required parameters missing',
          details: 'Please provide the required parameters in the request body',
          status: :bad_request
        )
        return {}
      end
    end
  end
end 