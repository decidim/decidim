# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing all the attachments for a voting.
      class VotingAttachmentsController < Decidim::Admin::ApplicationController
        include VotingAdmin
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          voting_attachments_path(current_voting)
        end

        def attached_to
          current_voting
        end
      end
    end
  end
end
