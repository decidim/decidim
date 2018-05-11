# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assembly members from the admin dashboard.
      #
      class AssemblyMemberForm < Form
        mimic :assembly_member

        attribute :weight, Integer, default: 0
        attribute :full_name, String
        attribute :gender, String
        attribute :birthday, Decidim::Attributes::TimeWithZone
        attribute :birthplace, String
        attribute :ceased_date, Decidim::Attributes::TimeWithZone
        attribute :designation_date, Decidim::Attributes::TimeWithZone
        attribute :designation_mode, String
        attribute :position, String
        attribute :position_other, String

        validates :full_name, :designation_date, presence: true
        validates :position, inclusion: { in: Decidim::AssemblyMember::POSITIONS }
        validates :position_other, presence: true, if: ->(form) { form.position == "other" }
        validates :ceased_date, date: { after: :designation_date, allow_blank: true }

        def positions_for_select
          Decidim::AssemblyMember::POSITIONS.map do |position|
            [
              I18n.t(position, scope: "decidim.admin.models.assembly_member.positions"),
              position
            ]
          end
        end
      end
    end
  end
end
