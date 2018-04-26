# frozen_string_literal: true

module Decidim
  #
  # Decorator for assembly members
  #
  class AssemblyMemberPresenter < SimpleDelegator
    def age
      (Time.current.strftime("%Y%m%d").to_i - birthday.strftime("%Y%m%d").to_i) / 10_000 if birthday
    end

    delegate :profile_url, :avatar_url, to: :user, allow_nil: true

    def personal_information
      [
        gender.presence,
        age,
        birthplace.presence
      ].compact.join(" / ")
    end

    def position
      return position_other if __getobj__.position == "other"

      I18n.t(__getobj__.position, scope: "decidim.admin.models.assembly_member.positions", default: "")
    end
  end
end
