# frozen_string_literal: true
module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    has_many :participatory_processes, foreign_key: "decidim_organization_id", class_name: Decidim::ParticipatoryProcess, inverse_of: :organization
    has_many :static_pages, foreign_key: "decidim_organization_id", class_name: Decidim::StaticPage, inverse_of: :organization

    validates :name, :host, uniqueness: true

    # def available_locales
    #   return attributes[:available_locales] if attributes[:available_locales].try(:any?)
    #   Decidim.available_locales
    # end
    #
    # def default_locale
    #   attributes[:default_locale].presence || I18n.locale
    # end
  end
end
