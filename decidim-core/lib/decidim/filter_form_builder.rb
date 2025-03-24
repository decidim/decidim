# frozen_string_literal: true

require "decidim/form_builder"

module Decidim
  # This custom FormBuilder is used to create resource filter forms
  class FilterFormBuilder < FormBuilder
    # This method is used to generate a section of options in a filter block.
    #
    # @param method [Symbol] The method associated to the filter object of the form builder.
    # @param collection [Array, Decidim::CheckBoxesTreeHelper::TreeNode] The collection
    #        used to display the options. It can be an array of options where each options
    #        if represented by an array containing a value and a name or a check_boxes_tree
    #        struct as defined in Decidim::CheckBoxesTreeHelper for more complex situations
    #        which require nested options.
    # @param label [String] The title of the section.
    # @param id [String] The id of the section.
    # @param options [Hash] Additional options. Except :type, the rest of options are passed
    #        to the partial used to generate the section.
    # @option options [Symbol, String] :type The type of selector to use with the collection.
    #         It can be check_boxes, radio_buttons or check_boxes_tree (used by default when
    #         tree struct is passed. The default selector for arrays is radio_buttons.
    #
    # @return [ActionView::OutputBuffer] the HTML of the generated collection filter.
    def collection_filter(method:, collection:, label:, id:, **options)
      type = options.delete(:type) || default_form_type_for_collection(collection)

      case type.to_s
      when "check_boxes", "check_box", "radio_buttons", "radio_button"
        options.merge!(builder_type: type.to_s.pluralize)
        type = "collection"
      when "check_boxes_tree"
        options.merge!(check_boxes_tree_id: check_boxes_tree_id(method.to_s.gsub(/\[|\]/, "_"), id))
      end

      @template.render(
        "decidim/shared/filters/#{type}",
        **options, method:,
                   collection:,
                   label:,
                   id:,
                   form: self
      )
    end

    def dropdown_label(item, method, options = {})
      @template.render("decidim/shared/filters/dropdown_label", **options, item:, method:, form: self)
    end

    private

    def check_boxes_tree_id(*args)
      args.map(&:to_s).join("_")
    end

    def default_form_type_for_collection(collection)
      return "radio_buttons" if collection.is_a?(Array)
      return "check_boxes_tree" if collection.is_a?(Decidim::CheckBoxesTreeHelper::TreeNode)
    end
  end
end
