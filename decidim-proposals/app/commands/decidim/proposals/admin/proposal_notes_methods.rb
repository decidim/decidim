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

        def notify_mentioned_users
          mentioned_users.each do |user|
            #TODO: Add mentions notifications
          end
        end
      end
    end
  end
end
