# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::Conferences::RegistrationType`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    RegistrationTypePresenter.new(action_log, view_helpers).present
      class RegistrationTypePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :i18n,
            description: :i18n,
            price: :integer
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.conferences.registration_type"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.conferences.registration_type.#{action}"
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
