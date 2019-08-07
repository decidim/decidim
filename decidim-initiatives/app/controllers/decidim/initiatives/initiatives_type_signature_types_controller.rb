# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativesTypeSignatureTypesController < Decidim::Initiatives::ApplicationController
      helper_method :allowed_signature_types_for_initiatives

      # GET /initiative_type_signature_types/search
      def search
        enforce_permission_to :search, :initiative_type_signature_types
        render layout: false
      end

      private

      def allowed_signature_types_for_initiatives
        @allowed_signature_types_for_initiatives ||= InitiativesType.find(params[:type_id]).allowed_signature_types_for_initiatives
      end
    end
  end
end
