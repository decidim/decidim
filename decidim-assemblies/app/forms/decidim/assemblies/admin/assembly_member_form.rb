# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assembly members from the admin dashboard.
      #
      class AssemblyMemberForm < Form
        mimic :assembly_member

        attribute :full_name, String
        attribute :gender, String
        attribute :origin, String
        attribute :birthday, Decidim::Attributes::TimeWithZone
        attribute :designation_date, Decidim::Attributes::TimeWithZone
        attribute :designation_mode, String
        attribute :position, String
        attribute :position_other, String

        validates :full_name, :designation_date, presence: true
        validates :gender, inclusion: { in: Decidim::AssemblyMember::GENDERS }
        validates :position, inclusion: { in: Decidim::AssemblyMember::POSITIONS }
        validates :position_other, presence: true, if: ->(form) { form.position == "other" }

        def genders_for_select
          Decidim::AssemblyMember::GENDERS.map do |gender|
            [
              I18n.t(gender, scope: "decidim.admin.models.assembly_member.genders"),
              gender
            ]
          end
        end

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
