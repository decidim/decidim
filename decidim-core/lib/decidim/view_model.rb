# frozen_string_literal: true

module Decidim
  autoload :ActionAuthorizationHelper, "decidim/action_authorization_helper"
  autoload :ResourceHelper, "decidim/resource_helper"

  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include Decidim::ScopesHelper
    include ActionController::Helpers
    include Decidim::ActionAuthorization
    include Decidim::ActionAuthorizationHelper
    include Decidim::ReplaceButtonsHelper
    include Cell::Caching::Notifications
    include Decidim::MarkupHelper
    include ::Webpacker::Helper

    delegate :current_organization, to: :controller

    delegate :redesigned_layout, :redesign_enabled?, to: :controller

    cache :show, if: :perform_caching?, expires_in: :cache_expiry_time do
      cache_hash
    end

    def current_user
      context&.dig(:current_user) || controller&.current_user
    end

    def call(*)
      identifier = self.class.name.sub(/Cell$/, "").underscore
      instrument(:cell, identifier: identifier) do |_payload|
        super
      end
    end

    private

    def render_template(template, options, &block)
      ActiveSupport::Notifications.instrument(
        "render_template.action_view",
        identifier: template.file,
        layout: nil
      ) do
        super
      end
    end

    def instrument(name, **options)
      ActiveSupport::Notifications.instrument("render_#{name}.action_view", options) do |payload|
        yield payload
      end
    end

    def perform_caching?
      cache_hash.present?
    end

    def cache_hash
      nil
    end

    def cache_expiry_time
      nil
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
