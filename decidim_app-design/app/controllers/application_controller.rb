# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Decidim::NeedsSnippets

  include Decidim::RedesignLayout
  redesign active: true

  include Decidim::NeedsOrganization
  include Decidim::LocaleSwitcher
  include Decidim::UseOrganizationTimeZone
  include Decidim::NeedsPermission
  include Decidim::PayloadInfo
  include Decidim::ImpersonateUsers
  include Decidim::HasStoredPath
  include Decidim::NeedsTosAccepted
  include Decidim::HttpCachingDisabler
  include Decidim::ActionAuthorization
  include Decidim::ForceAuthentication
  include Decidim::SafeRedirect
  include Decidim::UserBlockedChecker
  include Decidim::DisableRedirectionToExternalHost
  include Decidim::NeedsPasswordChange

  helper Decidim::MetaTagsHelper
  helper Decidim::DecidimFormHelper
  helper Decidim::LanguageChooserHelper
  helper Decidim::ReplaceButtonsHelper
  helper Decidim::TranslationsHelper
  helper Decidim::AriaSelectedLinkToHelper
  helper Decidim::MenuHelper
  helper Decidim::ComponentPathHelper
  helper Decidim::ViewHooksHelper
  helper Decidim::CardHelper
  helper Decidim::SanitizeHelper
  helper Decidim::TwitterSearchHelper

  protect_from_forgery with: :exception
end
