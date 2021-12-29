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
        attribute :non_user_avatar
        attribute :remove_non_user_avatar, Boolean, default: false
        attribute :gender, String
        attribute :birthday, Decidim::Attributes::LocalizedDate
        attribute :birthplace, String
        attribute :ceased_date, Decidim::Attributes::LocalizedDate
        attribute :designation_date, Decidim::Attributes::LocalizedDate
        attribute :position, String
        attribute :position_other, String
        attribute :user_id, Integer
        attribute :existing_user, Boolean, default: false

        validates :designation_date, presence: true
        validates :full_name, presence: true, unless: proc { |object| object.existing_user }
        validates :non_user_avatar, passthru: {
          to: Decidim::AssemblyMember,
          with: {
            # The member gets its organization context through the assembly
            # object which is why we need to create a dummy assembly in order
            # to pass the correct organization context to the file upload
            # validators.
            assembly: lambda do |form|
              Decidim::Assembly.new(organization: form.current_organization)
            end
          }
        }
        validates :position, presence: true, inclusion: { in: Decidim::AssemblyMember::POSITIONS }
        validates :position_other, presence: true, if: ->(form) { form.position == "other" }
        validates :ceased_date, date: { after: :designation_date, allow_blank: true }
        validates :user, presence: true, if: proc { |object| object.existing_user }

        def map_model(model)
          self.user_id = model.decidim_user_id
          self.existing_user = user_id.present?
        end

        def user
          @user ||= current_organization.user_entities.find_by(id: user_id)
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
