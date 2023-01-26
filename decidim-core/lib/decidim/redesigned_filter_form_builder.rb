# frozen_string_literal: true

require "decidim/form_builder"

module Decidim
  # This custom FormBuilder is used to create resource filter forms
  class RedesignedFilterFormBuilder < FormBuilder
    def collection_filter(method:, collection:, label_scope:, id:, **options)
      type = options.delete(:type) || default_form_type_for_collection(collection)

      case type.to_s
      when "check_boxes", "check_box", "radio_buttons", "radio_button"
        options.merge!(builder_type: type.to_s.pluralize)
        type = "collection"
      when "check_boxes_tree"
        options.merge!(check_boxes_tree_id: check_boxes_tree_id(method))
      end

      @template.render(
        "decidim/shared/filters/redesigned_#{type}",
        **options.merge(
          method:,
          collection:,
          label_scope:,
          id:,
          form: self
        )
      )
    end

    def dropdown_label(item, method, options = {})
      @template.render("decidim/shared/filters/dropdown_label", **options.merge(item:, method:, form: self))
    end

    private

    def check_boxes_tree_id(method)
      method
    end

    def default_form_type_for_collection(collection)
      return "radio_buttons" if collection.is_a?(Array)
      return "check_boxes_tree" if collection.is_a?(Decidim::CheckBoxesTreeHelper::TreeNode)
    end
  end
end
