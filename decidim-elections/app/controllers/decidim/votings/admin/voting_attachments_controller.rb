# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing all the attachments for a voting.
      class VotingAttachmentsController < Decidim::Admin::ApplicationController
        include VotingAdmin
        include Decidim::Admin::Concerns::HasAttachments
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          voting_attachments_path(current_voting)
        end

        def attached_to
          current_voting
        end

        private

        def tab_menu_name = :decidim_votings_attachments_menu
      end
    end
  end
end
