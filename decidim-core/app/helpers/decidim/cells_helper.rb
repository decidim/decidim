# frozen_string_literal: true

module Decidim
  module CellsHelper
    def from_context
      options[:from].presence || context[:from].presence
    end

    def proposals_controller?
      context[:controller].class.to_s == "Decidim::Proposals::ProposalsController"
    end

    def posts_controller?
      context[:controller].class.to_s == "Decidim::Blogs::PostsController"
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
      return unless proposals_controller?
      return if index_action?
      from_context.withdrawable_by?(current_user)
    end

    def flagable?
      return unless from_context
      return unless proposals_controller?
      return if index_action?
      return if from_context.official?
      true
    end
  end
end
