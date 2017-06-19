# frozen_string_literal: true

module Decidim
  # A page is used to add static content to the website, it can be useful so
  # organization can add their own terms and conditions, privacy policy or
  # other pages they might need from an admin panel.
  #
  # Pages with a default slug cannot be destroyed and its slug cannot be
  # modified.
  class StaticPage < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization", inverse_of: :static_pages

    validates :slug, presence: true, uniqueness: { scope: :organization }
    validates :slug, format: { with: /\A[a-z0-9-]+/ }

    # These pages will be created by default when registering an organization
    # and cannot be deleted.
    DEFAULT_PAGES = %w(faq terms-and-conditions accessibility).freeze

    before_destroy :can_be_destroyed?
    before_update :can_update_slug?

    # Whether this is slug of a default page or not.
    #
    # slug - The String with the value of the slug.
    #
    # Returns Boolean.
    def self.default?(slug)
      DEFAULT_PAGES.include?(slug)
    end

    # Whether this is page is a default one or not.
    #
    # Returns Boolean.
    def default?
      self.class.default?(slug)
    end

    # Customize to_param so when we want to create a link to a page we use the
    # slug instead of the id.
    #
    # Returns a String.
    def to_param
      slug
    end

    private

    def can_be_destroyed?
      throw(:abort) if default?
    end

    def can_update_slug?
      throw(:abort) if slug_changed? && self.class.default?(slug_was)
    end
  end
end
