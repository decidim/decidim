# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update scopes.
    class NavbarLinkForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String
      attribute :link, String
      attribute :weight, Integer
      attribute :organization_id, Integer
      attribute :target, String

      validates :link, format: { with: URI.regexp(%w(http https)) }, presence: true
      validates :title, translatable_presence: true, presence: true
      validates :weight, presence: true
      validates :organization_id, :link, presence: true
    end
  end
end
