# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ParticipatoryProcessScopesHelper
    Option = Struct.new(:id, :name)

    # Public: Returns a collection of the given participatory process scopes,
    # prepending a global scope. The global scope is at the beginning because it's
    # easier to be found there. Use this helper in places like `select` elements in
    # forms.
    #
    # participatory_process - a Decidim::ParticipatoryProcess.
    #
    # Returns an Array.
    def participatory_process_subscopes(participatory_process)
      [Option.new("", I18n.t("decidim.participatory_processes.scopes.global"))] +
        participatory_process.subscopes.map do |scope|
          Option.new(scope.id, translated_attribute(scope.name))
        end
    end
  end
end
