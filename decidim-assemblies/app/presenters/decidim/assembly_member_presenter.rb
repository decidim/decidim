# frozen_string_literal: true

module Decidim
  #
  # Decorator for assembly members
  #
  class AssemblyMemberPresenter < SimpleDelegator
    def position
      return __getobj__.position_other if __getobj__.position == "other"

      I18n.t(__getobj__.position, scope: "decidim.admin.models.assembly_member.positions", default: "-")
    end
  end
end
