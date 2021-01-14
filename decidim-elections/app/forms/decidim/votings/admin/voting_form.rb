# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This class holds a Form to create/update votings from Decidim's admin panel.
      class VotingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :slug, String
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :scope_id, Integer
        # attribute :attachment, AttachmentForm
        # attribute :photos, Array[String]
        # attribute :add_photos, Array

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :slug, presence: true, format: { with: Decidim::Votings::Voting.slug_format }
        validate :slug_uniqueness
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        # validate :notify_missing_attachment_if_errored

        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }

        alias organization current_organization

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.find_by(id: scope_id)
        end

        private

        def organization_votings
          Voting.where(organization: current_organization)
        end

        def slug_uniqueness
          return unless organization_votings
                        .where(slug: slug)
                        .where.not(id: context[:voting_id])
                        .any?

          errors.add(:slug, :taken)
        end

        # This method will add an error to the `photos` field only if there's
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end
      end
    end
  end
end
