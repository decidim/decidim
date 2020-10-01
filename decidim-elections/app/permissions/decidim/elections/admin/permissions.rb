# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :question, :answer
            case permission_action.action
            when :create, :update, :delete
              allow_if_not_started
            when :import_proposals
              allow_if_not_started
            end
          when :election
            case permission_action.action
            when :create, :read
              allow!
            when :delete, :update, :unpublish
              allow_if_not_started
            when :publish
              allow_if_valid_and_not_started
            end
          when :trustee
            case permission_action.action
            when :create, :delete
              allow!
            end
          when :trustee_participatory_space
            allow_if_not_related_to_any_election
          end

          permission_action
        end

        private

        def election
          @election ||= context.fetch(:election, nil)
        end

        def question
          @question ||= context.fetch(:question, nil)
        end

        def trustee_participatory_space
          @trustee_participatory_space ||= context.fetch(:trustee_participatory_space, nil)
        end

        def allow_if_not_started
          toggle_allow(election && !election.started?)
        end

        def allow_if_valid_and_not_started
          toggle_allow(election && !election.started? && election.valid_questions?)
        end

        def allow_if_not_related_to_any_election
          component_ids = trustee_participatory_space.participatory_space.components.where(manifest_name: "elections").pluck(:id)
          election_ids = Decidim::Elections::Election.where(decidim_component_id: component_ids).pluck(:id)
          trustee_elections = Decidim::Elections::ElectionsTrustee.where(
            decidim_elections_trustee_id: trustee_participatory_space.decidim_elections_trustee_id,
            decidim_elections_election_id: election_ids
          )
          toggle_allow(trustee_elections.empty?)
        end
      end
    end
  end
end
