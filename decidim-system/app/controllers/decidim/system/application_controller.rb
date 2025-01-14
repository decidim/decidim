# frozen_string_literal: true

module Decidim
  module System
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      include FormFactory
      include PayloadInfo
      include Headers::HttpCachingDisabler
      include DisableRedirectionToExternalHost
      include ActiveStorage::SetCurrent

      protect_from_forgery with: :exception, prepend: true

      helper Decidim::MetaTagsHelper
      helper Decidim::TranslationsHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::System::MenuHelper
      helper Decidim::ShortLinkHelper
      helper Decidim::ResourceHelper
    end
  end
end
