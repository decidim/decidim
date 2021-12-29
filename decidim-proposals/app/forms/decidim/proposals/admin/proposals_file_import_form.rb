# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import proposals from
      # a file.
      class ProposalsFileImportForm < Decidim::Admin::ImportForm
        attribute :user_group_id, Integer

        def user_groups
          Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
        end

        protected

        def user_group
          @user_group ||= Decidim::UserGroup.find_by(
            organization: current_organization,
            id: user_group_id.to_i
          )
        end

        def importer_context
          context[:user_group] = user_group
          context
        end
      end
    end
  end
end
