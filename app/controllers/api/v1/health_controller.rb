module Api
  module V1
    class HealthController < ApplicationController
      include BasicAuthConcern
      include ApiResponseConcern
      include JsonSchemaConcern
      include ErrorMessagesConcern
      before_action :basic_authenticate

      def index
        data_params = health_params
        return if data_params.empty?
        
        render_success({
          status: 'ok',
          message: data_params[:message]
        })
      end

      def create
        data_params = health_params
        return if data_params.empty?
        
        render_success(build_response_data(data_params, 'created'))
      end

      def update
        data_params = health_params
        return if data_params.empty?
        
        render_success(build_response_data(data_params, 'updated'))
      end

      def destroy
        data_params = health_params
        return if data_params.empty?
        
        render_success({
          status: 'deleted',
          message: 'DELETE request received',
          id: data_params[:id]
        })
      end

      private

      def build_response_data(data_params, action_type)
        response_data = {
          status: action_type,
          message: "#{action_type.upcase} request received"
        }

        # データが存在する場合のみ追加
        response_data[:data] = data_params[:data] if data_params[:data].present?
        response_data[:id] = data_params[:id] if data_params[:id].present?
        response_data[:settings] = data_params[:settings] if data_params[:settings].present?
        response_data[:metadata] = data_params[:metadata] if data_params[:metadata].present?
        response_data[:tags] = data_params[:tags] if data_params[:tags].present?
        response_data[:nested_data] = data_params[:nested_data] if data_params[:nested_data].present?

        response_data
      end

      def health_params
        case request.method
        when 'GET', 'DELETE'
          permitted_keys = request.get? ? [:message, :id] : [:id]
          permitted_params = params.permit(*permitted_keys)

          # 必須パラメータのバリデーション
          if request.get? && !permitted_params[:message].present?
            error_config = get_error_message(:missing_parameter, param_name: 'message')
            render_error(**error_config, status: :bad_request)
            return {}
          elsif request.delete? && !permitted_params[:id].present?
            error_config = get_error_message(:missing_parameter, param_name: 'id')
            render_error(**error_config, status: :bad_request)
            return {}
          end

          permitted_params
        else
          permitted_params = params.require(:health).permit(
            :id, 
            :data, 
            :message,
            settings: [:enabled, :timeout, :retry_count],
            metadata: [:version, :created_at, :tags],
            tags: [],
            nested_data: [:name, :value, sub_items: [:id, :label]]
          )
          
          # JSON Schemaバリデーション
          return permitted_params if validate_json_schema(params.to_unsafe_h, health_schema)
          
          {}
        end
      rescue ActionController::ParameterMissing => e
        error_config = get_error_message(:missing_parameters_body)
        render_error(**error_config, status: :bad_request)
        return {}
      end
    end
  end
end 