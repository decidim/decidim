# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # Custom ApplicationJob scoped to the admin panel.
      #
      class ImportMemberCsvJob < ApplicationJob
        queue_as :exports

        def perform(email, user_name, participatory_space, current_user)
          return if email.blank? || user_name.blank?

          params = {
            name: user_name,
            email: email.downcase.strip
          }
          member_form = MemberForm.from_params(params, participatory_space:)
                                  .with_context(
                                    current_user:,
                                    current_participatory_space: participatory_space
                                  )

          CreateMember.call(member_form, participatory_space, via_csv: true)
        end
      end
    end
  end
end
