# frozen_string_literal: true

module Decidim
  module Proposals
    module Abilities
      # Defines the abilities related to proposals for a logged in process admin user.
      # Intended to be used with `cancancan`.
      class ParticipatoryProcessAdminAbility < Decidim::Abilities::ParticipatoryProcessAdminAbility
        def define_participatory_process_abilities
          super

          can [:manage, :unreport, :hide], Proposal do |proposal|
            can_manage_process?(proposal.feature.participatory_space)
          end

          cannot :create, Proposal unless can_create_proposal?
          cannot :update, Proposal unless can_update_proposal?
        end

        private

        def current_settings
          @context.fetch(:current_settings, nil)
        end

        def feature_settings
          @context.fetch(:feature_settings, nil)
        end

        def current_feature
          @context.fetch(:current_feature, nil)
        end

        def can_create_proposal?
          current_settings.try(:creation_enabled?) &&
            feature_settings.try(:official_proposals_enabled) &&
            can_manage_process?(current_feature.try(:participatory_space))
        end

        def can_update_proposal?
          current_settings.try(:proposal_answering_enabled) &&
            feature_settings.try(:proposal_answering_enabled)
        end
      end
    end
  end
end
