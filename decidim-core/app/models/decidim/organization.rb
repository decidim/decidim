# frozen_string_literal: true
module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    has_many :participatory_processes, foreign_key: "decidim_organization_id", class_name: Decidim::ParticipatoryProcess, inverse_of: :organization
    has_many :static_pages, foreign_key: "decidim_organization_id", class_name: Decidim::StaticPage, inverse_of: :organization
    has_many :scopes, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: Decidim::Scope, inverse_of: :organization
    has_many :admins, -> { where("roles @> ?", "{admin}") }, foreign_key: "decidim_organization_id", class_name: Decidim::User
    has_many :users, foreign_key: "decidim_organization_id", class_name: Decidim::User

    validates :name, :host, uniqueness: true

    mount_uploader :homepage_image, Decidim::HomepageImageUploader
    mount_uploader :official_img_header, Decidim::OfficialImageHeaderUploader
    mount_uploader :official_img_footer, Decidim::OfficialImageFooterUploader
    mount_uploader :logo, Decidim::OrganizationLogoUploader
    mount_uploader :favicon, Decidim::OrganizationFaviconUploader

    def homepage_big_url
      homepage_image.big.url
    end
  end
end
