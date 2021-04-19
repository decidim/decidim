# frozen_string_literal: true

module Decidim
  module Assemblies
    module AdminLog
      # This class holds the logic to present a `Decidim::AssemblyMember`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    AssemblyMemberPresenter.new(action_log, view_helpers).present
      class AssemblyMemberPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            full_name: :string,
            gender: :string,
            birthday: :date,
            birthplace: :string,
            designation_date: :date,
            designation_mode: :string,
            position: "Decidim::Assemblies::AdminLog::ValueTypes::MemberPositionPresenter",
            position_other: :string,
            weight: :integer,
            ceased_date: :date
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.assembly_member"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.assembly_member.#{action}"
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
