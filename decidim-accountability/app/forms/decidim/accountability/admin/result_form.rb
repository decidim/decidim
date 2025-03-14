# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update results from Decidim's admin panel.
      class ResultForm < Decidim::Form
        include Decidim::TranslatableAttributes
        include Decidim::TranslationsHelper
        include Decidim::HasTaxonomyFormAttributes

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText

        attribute :proposal_ids, Array[Integer]
        attribute :project_ids, Array[Integer]
        attribute :start_date, Decidim::Attributes::LocalizedDate
        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :progress, Float
        attribute :decidim_accountability_status_id, Integer
        attribute :parent_id, Integer
        attribute :external_id, String
        attribute :weight, Float
        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float

        validates :title, translatable_presence: true

        validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: ->(form) { form.progress.present? }

        validates :parent, presence: true, if: ->(form) { form.parent_id.present? }
        validates :status, presence: true, if: ->(form) { form.decidim_accountability_status_id.present? }

        validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }

        def map_model(model)
          self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id)
          self.project_ids = model.linked_resources(:projects, "included_projects").pluck(:id)
        end

        def participatory_space_manifest
          @participatory_space_manifest ||= current_component.participatory_space.manifest.name
        end

        def proposals
          @proposals ||= Decidim.find_resource_manifest(:proposals)
                                .try(:resource_scope, current_component)
                                &.where(id: proposal_ids)
                                &.order(title: :asc)
        end

        def projects
          @projects ||= Decidim.find_resource_manifest(:projects).try(:resource_scope, current_component)&.order(title: :asc)
                               &.select(:title, :id)&.map { |a| [a.title[I18n.locale.to_s], a.id] }
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

        def parent
          @parent ||= Decidim::Accountability::Result.find_by(component: current_component, id: parent_id)
        end

        def status
          @status ||= Decidim::Accountability::Status.find_by(component: current_component, id: decidim_accountability_status_id)
        end
      end
    end
  end
end
