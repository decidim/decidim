# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # Custom ApplicationJob scoped to the admin panel.
      #
      class ImportMemberCsvJob < ApplicationJob
        queue_as :exports

        def perform(email, user_name, privatable_to, current_user)
          return if email.blank? || user_name.blank?

          params = {
            name: user_name,
            email: email.downcase.strip
          }
          member_form = MemberForm.from_params(params, privatable_to:)
                                  .with_context(
                                    current_user:,
                                    current_participatory_space: privatable_to
                                  )

          CreateMember.call(member_form, privatable_to, via_csv: true)
        end
      end
    end
  end
end
