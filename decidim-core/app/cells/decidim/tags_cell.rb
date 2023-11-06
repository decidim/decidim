# frozen_string_literal: true

module Decidim
  # This cell renders the category of a resource
  # shown with the translated name and links to
  # the resource parent `component` and `participatory space` index.
  # The context `resource` must be present
  # example use inside another `cell`:
  #   <%= cell("decidim/category", model.category, context: {resource: model}) %>
  #
  class TagsCell < Decidim::ViewModel
    def show
      render if category? || scope?
    end

    def category
      render if category?
    end

    def scope
      render if scope?
    end

    private

    def tags_classes
      (["tag-container"] + context[:extra_classes].to_a).join(" ")
    end

    def category?
      model.category.present?
    end

    # deprecated
    def link_to_category
      accessible_title = t("decidim.tags.filter_results_for_category", resource: category_name)

      link_to category_path, title: accessible_title, class: "tag" do
        sr_title = content_tag(
          :span,
          accessible_title,
          class: "sr-only"
        )
        display_title = content_tag(
          :span,
          category_name,
          "aria-hidden": true
        )

        sr_title + display_title
      end
    end

    def link_to_tag(path, name, title)
      link_to path, title:, class: "tag" do
        sr_title = content_tag(
          :span,
          title,
          class: "sr-only"
        )
        display_title = content_tag(
          :span,
          name,
          "aria-hidden": true
        )

        icon("price-tag-3-line") + sr_title + display_title
      end
    end

    def category_name
      model.category.translated_name
    end

    def category_path
      resource_locator(model).index(filter: { filter_param(:category) => [model.category.id.to_s] })
    end

    def scope?
      has_visible_scopes?(model)
    end

    # deprecated
    def link_to_scope
      accessible_title = t("decidim.tags.filter_results_for_scope", resource: scope_name)

      link_to scope_path, title: accessible_title, class: "tag" do
        sr_title = content_tag(
          :span,
          accessible_title,
          class: "sr-only"
        )
        display_title = content_tag(
          :span,
          scope_name,
          "aria-hidden": true
        )

        sr_title + display_title
      end
    end

    def scope_name
      translated_attribute model.scope.name
    end

    def scope_path
      resource_locator(model).index(filter: { filter_param(:scope) => [model.scope.id] })
    end

    def filter_param(name)
      candidates = ["with_any_#{name}".to_sym, "with_#{name}".to_sym]
      return candidates.first unless controller.respond_to?(:default_filter_params, true)

      available_params = controller.send(:default_filter_params)
      candidates.each do |candidate|
        return candidate if available_params.has_key?(candidate)
      end
      candidates.first
    end
  end
end
