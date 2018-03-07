# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::Proposals::ViewModel
      property :title

      def show
        render
      end

      def footer
        render
      end

      def header
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
        model.feature.current_settings
      end

      def current_feature
        model.feature
      end

      def current_participatory_space
        model.feature.participatory_space
      end

      def feature_settings
        model.feature.settings
      end

      def feature_name
        translated_attribute current_feature.name
      end

      def feature_type_name
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
