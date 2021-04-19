# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::Conferences::ConferenceRegistration`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ConferenceRegistrationPresenter.new(action_log, view_helpers).present
      class ConferenceRegistrationPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            confirmed_at: :date
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.conferences.conference_registration"
        end

        def action_string
          case action
          when "confirm"
            "decidim.admin_log.conferences.conference_registration.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
