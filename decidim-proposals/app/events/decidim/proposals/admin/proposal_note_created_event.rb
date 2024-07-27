# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalNoteCreatedEvent < Decidim::Events::SimpleEvent
        include Decidim::Events::AuthorEvent
        include Rails.application.routes.mounted_helpers

        i18n_attributes :admin_proposal_info_url, :admin_proposal_info_path

        def admin_proposal_info_path
          ResourceLocatorPresenter.new(resource).show
        end

        def admin_proposal_info_url
          send(resource.component.mounted_admin_engine).proposal_url(resource, resource.component.mounted_params)
        end

        private

        def author
          Decidim::User.find(extra[:note_author_id])
        end

        def organization
          @organization ||= component.participatory_space.organization
        end
      end
    end
  end
end
