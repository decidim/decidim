# frozen_string_literal: true

module Decidim
  module AdminLog
    module ParticipatorySpace
      # This class holds the logic to present a `Decidim::ParticipatorySpace::MemberPresenter`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    MemberPresenter.new(action_log, view_helpers).present
      class MemberPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :string,
            email: :string
          }
        end

        def action_string
          case action
          when "create", "create_via_csv", "delete"
            "decidim.admin_log.member.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.member"
        end
      end
    end
  end
end
