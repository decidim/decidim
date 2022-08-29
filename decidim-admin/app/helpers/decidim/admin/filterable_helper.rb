# frozen_string_literal: true

module Decidim
  module Admin
    # Helper that provides methods related to Decidim::Admin::Filterable concern.
    module FilterableHelper
      # Renders the filters selector with tags in the admin panel.
      def admin_filter_selector(i18n_ctx = nil)
        render partial: "decidim/admin/shared/filters", locals: { i18n_ctx: }
      end

      # Builds a tree of links from Decidim::Admin::Filterable::filters_with_values
      def submenu_options_tree(i18n_ctx = nil)
        i18n_scope = filterable_i18n_scope_from_ctx(i18n_ctx)

        filters_with_values.each_with_object({}) do |(filter, values), hash|
          link = filter_link_label(filter, i18n_scope)
          hash[link] = case values
                       when Array
                         build_submenu_options_tree_from_array(filter, values, i18n_scope)
                       when Hash
                         build_submenu_options_tree_from_hash(filter, values, i18n_scope)
                       end
        end
      end

      # Builds a tree of links from an array. The tree will have only one level.
      def build_submenu_options_tree_from_array(filter, values, i18n_scope)
        links = []
        links += extra_dropdown_submenu_options_items(filter, i18n_scope)
        links += values.map { |value| filter_link_value(filter, value, i18n_scope) }
        links.index_with { nil }
      end

      # To be overriden. Useful for adding links that do not match with the filter.
      # Must return an Array.
      def extra_dropdown_submenu_options_items(_filter, _i18n_scope)
        []
      end

      # Builds a tree of links from an Hash. The tree can have many levels.
      def build_submenu_options_tree_from_hash(filter, values, i18n_scope)
        values.each_with_object({}) do |(key, value), hash|
          link = filter_link_value(filter, key, i18n_scope)
          hash[link] = if value.nil?
                         nil
                       elsif value.is_a?(Hash)
                         build_submenu_options_tree_from_hash(filter, value, i18n_scope)
                       end
        end
      end

      # Produces the html for the dropdown submenu from the options tree.
      # Returns a ActiveSupport::SafeBuffer.
      def dropdown_submenu(options)
        content_tag(:ul, class: "vertical menu") do
          options.map do |key, value|
            if value.nil?
              content_tag(:li, key)
            elsif value.is_a?(Hash)
              content_tag(:li, class: "is-dropdown-submenu-parent") do
                key + dropdown_submenu(value)
              end
            end
          end.join.html_safe
        end
      end

      def filter_link_label(filter, i18n_scope)
        link_to(i18n_filter_label(filter, i18n_scope), href: "#")
      end

      def filter_link_value(filter, value, i18n_scope)
        link_to(i18n_filter_value(filter, value, i18n_scope), query_params_with(filter => value))
      end

      def i18n_filter_label(filter, i18n_scope)
        t("#{i18n_scope}.#{filter}.label")
      end

      def i18n_filter_value(filter, value, i18n_scope)
        if I18n.exists?("#{i18n_scope}.#{filter}.values.#{value}")
          t(value, scope: "#{i18n_scope}.#{filter}.values")
        else
          find_dynamic_translation(filter, value)
        end
      end

      def applied_filters_hidden_field_tags
        html = []
        html += ransack_params.slice(*filters, *extra_filters).map do |filter, value|
          hidden_field_tag("q[#{filter}]", value)
        end
        html += query_params.slice(*extra_allowed_params).map do |filter, value|
          hidden_field_tag(filter, value)
        end
        html.join.html_safe
      end

      def applied_filters_tags(i18n_ctx)
        ransack_params.slice(*filters).map do |filter, value|
          applied_filter_tag(filter, value, filterable_i18n_scope_from_ctx(i18n_ctx))
        end.join.html_safe
      end

      def applied_filter_tag(filter, value, i18n_scope)
        content_tag(:span, class: "label secondary") do
          concat "#{i18n_filter_label(filter, i18n_scope)}: "
          concat i18n_filter_value(filter, value, i18n_scope)
          concat remove_filter_icon_link(filter)
        end
      end

      def remove_filter_icon_link(filter)
        icon_link_to(
          "circle-x",
          url_for(query_params_without(filter)),
          t("decidim.admin.actions.cancel"),
          class: "action-icon--remove"
        )
      end

      def filterable_i18n_scope_from_ctx(i18n_ctx)
        i18n_scope = "decidim.admin.filters"
        i18n_scope += ".#{i18n_ctx}" if i18n_ctx
        i18n_scope
      end
    end
  end
end
