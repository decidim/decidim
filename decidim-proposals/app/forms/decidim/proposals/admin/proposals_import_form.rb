# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from another component.
      class ProposalsImportForm < Decidim::Form
        include TranslatableAttributes
        mimic :proposals_import

        attribute :origin_component_id, Integer
        attribute :keep_answers, Boolean
        attribute :keep_authors, Boolean
        attribute :states, Array[String]

        validates :origin_component_id, :origin_component, :states, :current_component, presence: true
        validate :valid_states

        def states_collection
          @states_collection ||= ProposalState.where(component: current_component) + [ProposalState.new(token: "not_answered",
                                                                                                        title: I18n.t(
                                                                                                          :not_answered, scope: "decidim.proposals.answers"
                                                                                                        ))]
        end

        def states
          super.compact_blank
        end

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components
          @origin_components ||= current_participatory_space.components.where.not(id: current_component.id).where(manifest_name: :proposals)
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def available_states(component_id = nil)
          scope = Decidim::Proposals::ProposalState
          scope = scope.where(component: Decidim::Component.find(component_id)) if component_id.present?

          states = scope.pluck(:token).uniq.map do |token|
            OpenStruct.new(token:, title: token.humanize)
          end

          states + [OpenStruct.new(token: "not_answered", title: I18n.t("decidim.proposals.answers.not_answered"))]
        end

        private

        def valid_states
          return if states.all? do |state|
            available_states(origin_component_id).pluck(:token).include?(state)
          end

          errors.add(:states, :invalid)
        end
      end
    end
  end
end
