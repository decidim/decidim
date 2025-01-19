# frozen_string_literal: true

module Decidim
  # This cell renders the taxonomies of a resource
  # shown with the translated name and links to
  # the resource parent `component` and `participatory space` index.
  # The context `resource` must be present
  # example use inside another `cell`:
  #   <%= cell("decidim/tags", model.taxonomies, context: {resource: model}) %>
  #
  class TagsCell < Decidim::ViewModel
    def show
      render if taxonomies.any?
    end

    private

    def tags_classes
      (["tag-container"] + context[:extra_classes].to_a).join(" ")
    end

    def taxonomies
      return [] unless model.respond_to?(:taxonomies)

      @taxonomies ||= model.taxonomies.map do |taxonomy|
        {
          name: decidim_sanitize_translated(taxonomy.name),
          url: resource_locator(model).index(filter: { with_any_taxonomies: [taxonomy.root_taxonomy&.id,taxonomy.id].compact_blank })
        }
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

    def filter_param(name)
      candidates = [:"with_any_#{name}", :"with_#{name}"]
      return candidates.first unless controller.respond_to?(:default_filter_params, true)

      available_params = controller.send(:default_filter_params)
      candidates.each do |candidate|
        return candidate if available_params.has_key?(candidate)
      end
      candidates.first
    end
  end
end
