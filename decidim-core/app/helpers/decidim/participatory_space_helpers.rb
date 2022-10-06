# frozen_string_literal: true

module Decidim
  module ParticipatorySpaceHelpers
    # Public: This method gets exposed on all controllers that have `ParticipatorySpaceContext`
    # included as a module.
    #
    # Through this method, you can access helpers that are unique to a particular participatory
    # space. These helpers are defined in the participatory space manifest, via the `context`
    # helper.
    #
    # Example:
    #
    #     # If you had a `ParticipatoryProcessHelper` with a `participatory_process_header` method
    #     participatory_process_helpers.participatory_process_header(current_participatory_space)
    #
    # Returns an Object that includes the Helpers as public methods.
    def participatory_space_helpers
      return @participatory_space_helpers if defined?(@participatory_space_helpers)

      helper = current_participatory_space_manifest.context(current_participatory_space_context).helper

      klass = Class.new(SimpleDelegator) do
        include helper.constantize if helper
      end

      @participatory_space_helpers = klass.new(self)
    end

    def participatory_space_floating_help
      return if help_section.blank?

      content_tag "div", class: "row collapse" do
        floating_help(help_id) { translated_attribute(help_section).html_safe }
      end
    end

    def participatory_space_wrapper(&)
      content_tag :div, class: "wrapper" do
        concat(participatory_space_floating_help)
        concat(capture(&))
      end
    end
  end
end
