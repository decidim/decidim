# frozen_string_literal: true

module Decidim
  module CellsHelper
    def from_context
      options[:from].presence || context[:from].presence
    end

    def index_action?
      context[:controller].action_name == "index"
    end

    def show_action?
      context[:controller].action_name == "show"
    end

    def current_component
      from_context.component
    end

    def withdrawable?
      return unless from_context
      return unless context[:controller].try(:withdrawable_controller?)
      return if index_action?

      from_context.withdrawable_by?(current_user)
    end

    def flaggable?
      return unless from_context
      return unless context[:controller].try(:flaggable_controller?)
      return if index_action?

      true
    end

    def user_flaggable?
      return unless context[:controller].try(:flaggable_controller?)

      true
    end
  end
end
