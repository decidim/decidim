# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the proposal card for an instance of a Proposal
    # the default size is the Medium Card (:m)
    class ProposalCell < Decidim::ViewModel
      include ProposalCellsHelper
      include Cell::ViewModel::Partial
      include Messaging::ConversationHelper

      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/proposals/proposal_s"
        when :g
          "decidim/proposals/proposal_g"
        else
          "decidim/proposals/proposal_l"
        end
      end

      def resource_path
        resource_locator(model).path
      end

      def current_participatory_space
        model.component.participatory_space
      end

      def current_component
        model.component
      end

      def component_name
        translated_attribute model.component.name
      end

      def component_type_name
        model.class.model_name.human
      end

      def participatory_space_name
        translated_attribute current_participatory_space.title
      end

      def participatory_space_type_name
        translated_attribute current_participatory_space.model_name.human
      end
    end
  end
end
