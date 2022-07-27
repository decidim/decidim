# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create consultations from the admin dashboard.
      class ConsultationForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        mimic :consultation

        translatable_attribute :title, String
        translatable_attribute :subtitle, String
        translatable_attribute :description, String
        attribute :slug, String
        attribute :banner_image
        attribute :remove_banner_image, Boolean, default: false
        attribute :introductory_video_url, String
        attribute :introductory_image
        attribute :remove_introductory_image, Boolean, default: false
        attribute :decidim_highlighted_scope_id, Integer
        attribute :start_voting_date, Decidim::Attributes::LocalizedDate
        attribute :end_voting_date, Decidim::Attributes::LocalizedDate

        validates :slug, presence: true, format: { with: Decidim::Consultation.slug_format }
        validates :title, :subtitle, :description, translatable_presence: true
        validates :decidim_highlighted_scope_id, presence: true
        validates :start_voting_date, presence: true, date: { before_or_equal_to: :end_voting_date }
        validates :end_voting_date, presence: true, date: { after_or_equal_to: :start_voting_date }
        validate :slug_uniqueness

        validates :banner_image, passthru: { to: Decidim::Consultation }
        validates :introductory_image, passthru: { to: Decidim::Consultation }

        alias organization current_organization

        def highlighted_scope
          @highlighted_scope ||= current_organization.scopes.find_by(id: decidim_highlighted_scope_id)
        end

        private

        def slug_uniqueness
          return unless OrganizationConsultations
                        .new(current_organization)
                        .query
                        .where(slug:)
                        .where.not(id: context[:consultation_id]).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
