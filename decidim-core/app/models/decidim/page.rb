# frozen_string_literal: true
module Decidim
  # A page is used to add static content to the website, it can be useful so
  # organization can add their own terms and conditions, privacy policy or
  # other pages they might need from an admin panel.
  class Page < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: Decidim::Organization, inverse_of: :pages

    validates :slug, :organization, presence: true
    validates :slug, uniqueness: { scope: :organization }

    DEFAULT_PAGES = %w(faq terms-and-conditions).freeze

    # Customize to_param so when we want to create a link to a page we use the
    # slug instead of the id.
    #
    # Returns a String.
    def to_param
      slug
    end
  end
end
