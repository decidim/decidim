# frozen_string_literal: true

module Decidim
  # Exposes the scopes text search so users can choose a scope writing its name.
  class ScopesController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def picker
      enforce_permission_to :pick, :scope

      context = picker_context(root, title, max_depth)
      required = params&.[](:required) != "false"

      scopes, parent_scopes = resolve_picker_scopes(root, current)

      render(
        :picker,
        layout: nil,
        locals: {
          required:,
          title:,
          root:,
          current: (current || root),
          scopes: scopes&.order(name: :asc),
          parent_scopes:,
          picker_target_id: (params[:target_element_id] || "content"),
          global_value: params[:global_value],
          max_depth:,
          context:
        }
      )
    end

    private

    def picker_context(root, title, max_depth)
      root ? { root: root.id, title:, max_depth: } : { title:, max_depth: }
    end

    def resolve_picker_scopes(root, current)
      scopes = nil
      if current
        scopes = current.children unless scope_depth_limit?
        parent_scopes = current.part_of_scopes(root)
      else
        scopes = root&.children || current_organization.scopes.top_level unless scope_depth_limit?
        parent_scopes = [root].compact
      end
      [scopes, parent_scopes]
    end

    def title
      @title ||= params[:title] || t("decidim.scopes.picker.title", field: params[:field]&.downcase)
    end

    def root
      return if params[:root].blank?

      @root ||= current_organization.scopes.find(params[:root])
    end

    def current
      return if params[:current].blank?

      @current ||= (root&.descendants || current_organization.scopes).find_by(id: params[:current])
    end

    def filter_scope_depth?
      @filter_scope_depth ||= params[:max_depth].present?
    end

    def scope_depth_limit?
      return unless filter_scope_depth?

      @scope_depth_limit ||= current&.scope_type == max_depth
    end

    def max_depth
      return unless filter_scope_depth?

      @max_depth ||= current_organization.scope_types.find(params[:max_depth])
    end
  end
end
