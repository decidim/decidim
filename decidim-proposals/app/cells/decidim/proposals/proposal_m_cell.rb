# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::ViewModel
      self.view_paths << "#{Decidim::Core::Engine.root}/app/views"
      self.view_paths << "#{Decidim::Proposals::Engine.root}/app/cells"
      self.view_paths << "#{Decidim::Proposals::Engine.root}/app/views"

      include Decidim::LayoutHelper
      include Decidim::ApplicationHelper
      include Decidim::ActionAuthorizationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper
      include Decidim::Proposals::ApplicationHelper
      include Decidim::ResourceReferenceHelper

      include Decidim::Proposals::Engine.routes.url_helpers

      include Partial

      def model_path
        resource_locator(model).path
      end

      def current_settings
        controller.current_settings
      end

      def feature_settings
        controller.feature_settings
      end

      def action_authorization(action)
        controller.action_authorization(action)
      end

      def current_user
        controller.current_user
      end
    end
  end
end
