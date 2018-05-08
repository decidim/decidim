# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the proposal card for an instance of a Proposal
    # the default size is the Medium Card (:m)
    class ProposalCell < Decidim::Proposals::ViewModel
      include Cell::ViewModel::Partial
      include Messaging::ConversationHelper

      delegate :user_signed_in?, to: :parent_controller

      property :title
      property :state
      property :answered?
      property :withdrawn?

      def show
        cell card_size, model, @options
      end

      private

      def current_user
        context[:current_user]
      end

      def card_size
        "decidim/proposals/proposal_m"
      end

      def actionable?
        proposals_controller? && index_action? && current_settings.votes_enabled? && !model.draft?
      end

      def proposals_controller?
        context[:controller].class.to_s == "Decidim::Proposals::ProposalsController"
      end

      def index_action?
        context[:controller].action_name == "index"
      end

      def resource_path
        resource_locator(model).path
      end

      def current_settings
        model.component.current_settings
      end

      def current_component
        model.component
      end

      def current_participatory_space
        model.component.participatory_space
      end

      def component_settings
        model.component.settings
      end

      def component_name
        translated_attribute current_component.name
      end

      def component_type_name
        model.class.model_name.human
      end

      def from_context
        @options[:from]
      end

      def participatory_space_name
        translated_attribute current_participatory_space.title
      end

      def participatory_space_type_name
        translated_attribute current_participatory_space.model_name.human
      end

      def state_name
        humanize_proposal_state state
      end

      def badge_state_css
        case state
        when "accepted"
          "success"
        when "rejected"
          "alert"
        when "evaluating"
          "warning"
        when "withdrawn"
          "alert"
        else
          "muted"
        end
      end
    end
  end
end
