# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from another component into projects component.
      class ProjectImportProposalsForm < Decidim::Form
        mimic :proposals_import

        attribute :origin_component_id, Integer
        attribute :default_budget, Integer
        attribute :statuses, Array[String]

        validates :origin_component_id, :origin_component, :current_component, presence: true
        validates :default_budget, presence: true, numericality: { greater_than: 0 }
        validate :valid_statuses

        def statuses
          super.compact_blank
        end

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components
          @origin_components ||= current_participatory_space.components.where(manifest_name: :proposals)
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def budget
          @budget ||= context[:budget]
        end

        private

        def valid_statuses
          return unless origin_component
          return if statuses.empty?

          valid_tokens = Decidim::Proposals::ProposalStatus.where(component: origin_component).pluck(:token) + ["not_answered"]
          return if statuses.all? { |status| valid_tokens.include?(status) }

          errors.add(:statuses, :invalid)
        end
      end
    end
  end
end
