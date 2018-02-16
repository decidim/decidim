# frozen_string_literal: true

module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module ApplicationHelper
      include Decidim::LocalizedLocalesHelper
      include Decidim::TranslationsHelper
      include Decidim::HumanizeBooleansHelper
      include Decidim::AriaSelectedLinkToHelper
      include Decidim::MetaTagsHelper
      include Decidim::MapHelper
      include Decidim::Admin::LogRenderHelper

      def title
        current_organization.name
      end

      def foundation_datepicker_locale_tag
        javascript_include_tag "datepicker-locales/foundation-datepicker.#{I18n.locale}.js" if I18n.locale != :en
      end
    end
  end
end
