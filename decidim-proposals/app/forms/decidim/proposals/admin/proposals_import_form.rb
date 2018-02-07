# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from another component.
      class ProposalsImportForm < Decidim::Form
        mimic :proposals_import

        attribute :origin_feature_id, Integer
        attribute :import_proposals, Boolean
        attribute :states, Array

        validates :origin_feature_id, :origin_feature, :states, :current_feature, presence: true
        validates :import_proposals, allow_nil: false, acceptance: true
        validate :valid_states

        VALID_STATES = %w(accepted not_answered evaluating rejected withdrawn).freeze

        def states_collection
          VALID_STATES.map do |state|
            OpenStruct.new(
              name: I18n.t(state, scope: "decidim.proposals.answers"),
              value: state
            )
          end
        end

        def states
          super.reject(&:blank?)
        end

        def origin_feature
          @origin_feature ||= origin_features.find_by(id: origin_feature_id)
        end

        def origin_features
          @origin_features ||= current_participatory_space.features.where.not(id: current_feature.id).where(manifest_name: :proposals)
        end

        def origin_features_collection
          origin_features.map do |feature|
            [feature.name[I18n.locale.to_s], feature.id]
          end
        end

        private

        def valid_states
          return if states.all? do |state|
            VALID_STATES.include?(state)
          end

          errors.add(:states, :invalid)
        end
      end
    end
  end
end
