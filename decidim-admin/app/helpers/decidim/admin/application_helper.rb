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

      def title
        current_organization.name
      end

      def foundation_datepicker_locale_tag
        if I18n.locale != :en
          javascript_include_tag "datepicker-locales/foundation-datepicker.#{I18n.locale}.js"
        end
      end
    end
  end
end
