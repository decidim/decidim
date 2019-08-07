# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      # This class holds the logic to present a `Decidim::Proposals::ProposalNote`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ProposalNotePresenter.new(action_log, view_helpers).present
      class ProposalNotePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            body: :string
          }
        end

        def action_string
          case action
          when "create"
            "decidim.proposals.admin_log.proposal_note.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.proposal_note"
        end
      end
    end
  end
end
