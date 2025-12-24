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
        attribute :internal_states, Array[String]

        validates :origin_component_id, :origin_component, :current_component, presence: true
        validates :default_budget, presence: true, numericality: { greater_than: 0 }

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

        def available_states(component_id = nil)
          scope = Decidim::Proposals::ProposalState
          scope = scope.where(component: Decidim::Component.find(component_id)) if component_id.present?

          states = scope.pluck(:token).uniq.map do |token|
            OpenStruct.new(token: token, title: token.humanize)
          end

          states + [OpenStruct.new(token: "not_answered", title: I18n.t("decidim.proposals.answers.not_answered"))]
        end
      end
    end
  end
end
