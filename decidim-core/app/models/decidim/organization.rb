# frozen_string_literal: true
module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    has_many :participatory_processes, foreign_key: "decidim_organization_id", class_name: Decidim::ParticipatoryProcess, inverse_of: :organization
    has_many :static_pages, foreign_key: "decidim_organization_id", class_name: Decidim::StaticPage, inverse_of: :organization
    has_many :scopes, foreign_key: "decidim_organization_id", class_name: Decidim::Scope, inverse_of: :organization

    validates :name, :host, uniqueness: true
    validates :homepage_image, file_size: { less_than_or_equal_to: 10.megabytes }, on: :create

    mount_uploader :homepage_image, Decidim::HomepageImageUploader

    def homepage_big_url
      homepage_image&.big&.url
    end
  end
end
