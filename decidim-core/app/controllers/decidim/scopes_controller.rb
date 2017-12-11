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

    def picker
      authorize! :pick, Scope

      title = params[:title] || t("decidim.scopes.picker.title", field: params[:field]&.downcase)
      root = Scope.find(params[:root]) if params[:root]
      context = root ? { root: root.id, title: title } : { title: title }
      required = params[:required] && params[:required] != "false"
      if params[:current]
        current = Scope.find(params[:current])
        scopes = current.children
        parent_scopes = current.part_of_scopes
      else
        current = root
        scopes = root&.children || Scope.top_level
        parent_scopes = [root].compact
      end
      render :picker, layout: nil, locals: { required: required, title: title, root: root, current: current, scopes: scopes.order(name: :asc),
                                             parent_scopes: parent_scopes, context: context }
    end
  end
end
