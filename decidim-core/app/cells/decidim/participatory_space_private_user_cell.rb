# frozen_string_literal: true

module Decidim
  # This cell renders the card for an instance of an Assembly member
  class ParticipatorySpacePrivateUserCell < Decidim::ViewModel
    property :name
    property :role
    property :nickname
    property :profile_url

    private

    def has_profile?
      model.profile_url.present?
    end

    def role_translated
      decidim_html_escape(decidim_sanitize(translated_attribute(role)))
    end
  end
end
