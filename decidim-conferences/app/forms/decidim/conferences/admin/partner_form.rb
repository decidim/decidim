# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference members from the admin dashboard.
      class PartnerForm < Form
        mimic :conference_partner

        attribute :name, String
        attribute :link, String
        attribute :partner_type, String
        attribute :weight, Integer, default: 0
        attribute :logo
        attribute :remove_logo

        validates :name, :partner_type, presence: true, if: ->(form) { form.logo.present? }
        validates :logo, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }
        validate :link_format
        validates :weight, numericality: { greater_than_or_equal_to: 0 }
        validates :partner_type, inclusion: { in: Decidim::Conferences::Partner::TYPES }

        def link
          return if super.blank?

          return "http://" + super unless super.match?(%r{\A(http|https)://}i)

          super
        end

        def types
          Decidim::Conferences::Partner::TYPES.map do |type|
            [
              I18n.t(type, scope: "decidim.admin.models.partner.types"),
              type
            ]
          end
        end

        private

        def link_format
          return if link.blank?

          uri = URI.parse(link)
          errors.add :link, :invalid if !uri.is_a?(URI::HTTP) || uri.host.nil?
        rescue URI::InvalidURIError
          errors.add :link, :invalid
        end
      end
    end
  end
end
