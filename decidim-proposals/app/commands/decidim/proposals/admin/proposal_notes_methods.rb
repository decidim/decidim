# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A module with common methods of proposal notes commands
      module ProposalNotesMethods
        private

        def parsed_body
          @parsed_body ||= Decidim::ContentProcessor.parse_with_processor(:user, form.body, current_organization: form.current_organization)
        end

        def mentioned_users
          @mentioned_users ||= parsed_body.metadata[:user].users
        end

        def rewritten_body
          @rewritten_body ||= parsed_body.rewrite
        end

        def proposal_valuators
          @proposal_valuators ||= Decidim::Proposals::ValuationAssignment.where(proposal:).filter_map do |assignment|
            assignment.valuator unless assignment.valuator == form.current_user
          end
        end

        def admins
          @admins ||= Decidim::User.org_admins_except_me(form.current_user).all
        end

        def space_admins
          @space_admins ||= proposal.participatory_space.user_roles("admin").includes(:user).filter_map do |role|
            role.user unless role.user == form.current_user
          end
        end

        def mentioned_admins_or_valuators
          mentioned_users.select do |user|
            admins.exists?(user.id) ||
              space_admins.include?(user) ||
              proposal_valuators.include?(user)
          end
        end
      end
    end
  end
end
