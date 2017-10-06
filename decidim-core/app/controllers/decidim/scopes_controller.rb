# frozen_string_literal: true

module Decidim
  # Exposes the scopes text search so users can choose a scope writing its name.
  class ScopesController < Decidim::ApplicationController
    def search
      authorize! :search, Scope
      root = Scope.where(id: params[:root], organization: current_organization).first
      scopes = if params[:term].present?
                 FreetextScopes.for(current_organization, I18n.locale, params[:term], root)
               elsif root
                 root.children
               else
                 current_organization.top_scopes
               end
      root_option = if params[:include_root] == "true" && params[:term].blank?
                      if root
                        [{ id: root.id.to_s, text: root.name[I18n.locale.to_s] }]
                      else
                        [{ id: "global", text: I18n.t("decidim.scopes.global") }]
                      end
                    else
                      []
                    end

      render json: { results: root_option + scopes.map { |scope| { id: scope.id.to_s, text: scope.name[I18n.locale.to_s] } } }
    end
  end
end
