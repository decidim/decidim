# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes the initiative type text search so users can choose a type writing its name.
    class InitiativesTypeScopesController < Decidim::Initiatives::ApplicationController
      helper_method :scoped_types

      # GET /initiative_type_scopes/search
      def search
        enforce_permission_to :search, :initiative_type_scope
        render layout: false
      end

      private

      def scoped_types
        @scoped_types ||= if initiative_type.only_global_scope_enabled?
                            initiative_type.scopes.where(scope: nil)
                          else
                            initiative_type.scopes
                          end
      end

      def initiative_type
        @initiative_type ||= InitiativesType.find(params[:type_id])
      end
    end
  end
end
