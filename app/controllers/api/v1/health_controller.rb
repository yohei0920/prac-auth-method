module Api
  module V1
    class HealthController < ApplicationController
      include BasicAuthConcern
      before_action :basic_authenticate

      def index
        render json: { status: 'ok' }
      end
    end
  end
end 