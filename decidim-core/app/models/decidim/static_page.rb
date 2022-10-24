# frozen_string_literal: true

module Decidim
  # A page is used to add static content to the website, it can be useful so
  # organization can add their own terms and conditions, privacy policy or
  # other pages they might need from an admin panel.
  #
  # Pages with a default slug cannot be destroyed and its slug cannot be
  # modified.
  class StaticPage < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource

    translatable_fields :title, :content

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization", inverse_of: :static_pages
    belongs_to :topic, class_name: "Decidim::StaticPageTopic", optional: true

    validates :slug, presence: true, uniqueness: { scope: :organization }
    validates :slug, format: { with: /\A[a-z0-9-]+/ }

    # These pages will be created by default when registering an organization
    # and cannot be deleted.
    DEFAULT_PAGES = %w(terms-and-conditions).freeze

    after_create :update_organization_tos_version
    before_destroy :can_be_destroyed?
    before_update :can_update_slug?

    default_scope { order(arel_table[:weight].asc) }

    scope :accessible_for, lambda { |organization, user|
      collection = where(organization:)

      if user.blank? && organization.force_users_to_authenticate_before_access_organization
        collection.where(allow_public_access: true)
      else
        collection
      end
    }

    # Whether this is slug of a default page or not.
    #
    # slug - The String with the value of the slug.
    #
    # Returns Boolean.
    def self.default?(slug)
      DEFAULT_PAGES.include?(slug)
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::StaticPagePresenter
    end

    def self.sorted_by_i18n_title(locale = I18n.locale)
      order([Arel.sql("title->? ASC"), locale])
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

    # When creating a terms-and-conditions page
    # set the organization tos_version
    def update_organization_tos_version
      return unless slug == "terms-and-conditions"

      organization.update!(tos_version: created_at)
    end

    def can_be_destroyed?
      throw(:abort) if default?
    end

    def can_update_slug?
      throw(:abort) if slug_changed? && self.class.default?(slug_was)
    end
  end
end
