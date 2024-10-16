# frozen_string_literal: true

class MigrateAssemblyMembersToPrivateUsers < ActiveRecord::Migration[7.0]
  def up
    ::Decidim::AssemblyMember.find_each do |assembly_member|
      next if assembly_member.ceased_date
      next unless assembly_member.user

      attrs = { privatable_to: assembly_member.assembly, user: assembly_member.user }

      next if ::Decidim::ParticipatorySpacePrivateUser.find_by(attrs)

      role = case assembly_member.position
             when "president"
               translated_role("decidim.admin.models.assembly_member.positions.president")
             when "vice_president"
               translated_role("decidim.admin.models.assembly_member.positions.vice_president")
             when "secretary"
               translated_role("decidim.admin.models.assembly_member.positions.secretary")
             when "other"
               { I18n.locale.to_s => assembly_member.position_other }
             end

      Rails.logger.debug { "Migrating assembly member #{assembly_member.id} to private user" }

      ::Decidim::ParticipatorySpacePrivateUser.create!(attrs.merge(role:))
    end
  end

  def down; end

  private

  def translated_role(key)
    I18n.available_locales.each_with_object({}) do |locale, hash|
      I18n.with_locale(locale) do
        hash[locale.to_s] = I18n.t(key)
      end
    end
  end
end
