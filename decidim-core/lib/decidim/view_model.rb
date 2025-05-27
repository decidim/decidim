# frozen_string_literal: true

module Decidim
  autoload :ActionAuthorizationHelper, "decidim/action_authorization_helper"
  autoload :ResourceHelper, "decidim/resource_helper"

  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include ActionController::Helpers
    include Decidim::ActionAuthorization
    include Decidim::ActionAuthorizationHelper
    include Decidim::ReplaceButtonsHelper
    include Cell::Caching::Notifications
    include Decidim::MarkupHelper
    include Decidim::LayoutHelper
    include Decidim::SanitizeHelper
    include Decidim::ApplicationHelper
    include Decidim::IconHelper

    delegate :helper_method, to: :controller
    delegate :current_organization, to: :controller
    delegate_missing_to :view_context

    cache :show, if: :perform_caching?, expires_in: :cache_expiry_time do
      cache_hash
    end

    def current_user
      context&.dig(:current_user) || controller&.current_user
    end

    def call(*)
      identifier = self.class.name.sub(/Cell$/, "").underscore
      instrument(:cell, identifier:) do |_payload|
        super
      end
    end

    def current_locale
      I18n.locale
    end

    # Rails cells is delegating those methods to some internal view layer which messes up with shakapacker asset loading strategy
    # generating 2 or more queues for the javascript to be loading, resulting in the fact that no js / style pack appended or
    # prepended is added to main view rendering queue.
    # This is inspired from : https://github.com/trailblazer/cells-rails/blob/master/lib/cell/helper/asset_helper.rb
    %w(
      asset_pack_path
      asset_pack_url
      image_pack_path
      image_pack_url
      image_pack_tag
      favicon_pack_tag
      javascript_pack_tag
      preload_pack_asset
      stylesheet_pack_tag
      append_stylesheet_pack_tag
      append_javascript_pack_tag
      prepend_javascript_pack_tag
    ).each do |method|
      delegate method, to: :view_context
    end

    def view_context
      context&.dig(:view_context) || ::ActionController::Base.helpers
    end

    private

    def render_template(template, options, &)
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
      Decidim.cache_expiry_time
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
