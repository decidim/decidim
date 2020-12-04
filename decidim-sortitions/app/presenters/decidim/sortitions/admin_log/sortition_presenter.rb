# frozen_string_literal: true

module Decidim
  module Sortitions
    module AdminLog
      # This class holds the logic to present a `Decidim::Sortitions::Sortition`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    SortitionPresenter.new(action_log, view_helpers).present
      class SortitionPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.sortitions.admin_log.sortition.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            cancel_reason: :i18n,
            dice: :integer,
            request_timestamp: :date,
            witnesses: :i18n,
            additional_info: :i18n,
            title: :i18n,
            reference: :string,
            decidim_proposals_component_id: :component
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.sortition"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
