# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This class holds a Form to create/update projects from Decidim's admin panel.
      class ProjectForm < Decidim::Form
        include Decidim::TranslatableAttributes
        include Decidim::HasTaxonomyFormAttributes
        include Decidim::AttachmentAttributes
        include Decidim::TranslationsHelper
        include Decidim::ApplicationHelper

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :budget_amount, Integer
        attribute :proposal_ids, Array[Integer]
        attribute :attachment, AttachmentForm
        attribute :selected, Boolean

        attachments_attribute :photos

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :budget_amount, presence: true, numericality: { greater_than: 0 }
        validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }

        validate :notify_missing_attachment_if_errored

        alias component current_component

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)
          self.selected = model.selected?
        end

        def participatory_space_manifest
          @participatory_space_manifest ||= current_component.participatory_space.manifest.name
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, current_component)
                         &.where(id: proposal_ids)
                         &.order(title: :asc)
        end

        def geocoding_enabled?
          Decidim::Map.available?(:geocoding) && current_component.settings.geocoding_enabled?
        end

        def has_address?
          geocoding_enabled? && address.present?
        end

        def geocoded?
          latitude.present? && longitude.present?
        end

        # Finds the Budget from the decidim_budgets_budget_id.
        #
        # Returns a Decidim::Budgets:Budget
        def budget
          @budget ||= context[:budget]
        end

        private

        # This method will add an error to the `attachment` field only if there is
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end
      end
    end
  end
end
