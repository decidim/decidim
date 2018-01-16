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
  end
end
