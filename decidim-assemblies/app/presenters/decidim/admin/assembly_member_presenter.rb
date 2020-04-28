# frozen_string_literal: true

module Decidim
  module Admin
    #
    # Decorator for assembly members
    #
    class AssemblyMemberPresenter < SimpleDelegator
      def name
        if user
          "#{user.name} (#{Decidim::UserPresenter.new(user).nickname})"
        else
          full_name
        end
      end

      def position
        return position_other if __getobj__.position == "other"

        I18n.t(__getobj__.position, scope: "decidim.admin.models.assembly_member.positions", default: "")
      end
    end
  end
end
