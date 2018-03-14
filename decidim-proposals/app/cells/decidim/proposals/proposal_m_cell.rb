# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::Proposals::ViewModel
      include Partial

      property :title
      property :state
      property :answered?
      property :withdrawn?

      def show
        render
      end

      def footer
        render
      end

      def header
        render
      end

      def badge
        render
      end

      private

      def resource_path
        resource_locator(model).path
      end

      def from_inside?
        true if context[:from].to_s.include?(:inside.to_s)
      end

      def from_outside?
        true if context[:from].to_s.include?(:outside.to_s)
      end

      def body
        truncate(model.body, length: 100)
      end

      def controller
        context[:controller] || controller
      end

      def current_user
        controller.current_user
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
          "warning"
        when "evaluating"
          "muted"
        when "withdrawn"
          "alert"
        else
          ""
        end
      end
    end
  end
end
