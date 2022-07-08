# frozen_string_literal: true

module Decidim
  module Initiatives
    module AdminLog
      # This class holds the logic to present a `Decidim::InitiativesType`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    InitiativesTypePresenter.new(action_log, view_helpers).present
      class InitiativesTypePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "update", "delete"
            "decidim.initiatives.admin_log.initiatives_type.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            description: :i18n,
            title: :i18n,
            extra_fields_legal_information: :i18n,
            minimum_committee_members: :integer,
            document_number_authorization_handler: :i18n,
            undo_online_signatures_enabled: :boolean,
            promoting_committee_enabled: :boolean
          }
        end

        def diff_actions
          super + %w(update)
        end
      end
    end
  end
end
