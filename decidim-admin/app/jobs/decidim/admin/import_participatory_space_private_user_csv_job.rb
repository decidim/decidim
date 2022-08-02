# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class ImportParticipatorySpacePrivateUserCsvJob < ApplicationJob
      queue_as :exports

      def perform(email, user_name, privatable_to, current_user)
        return if email.blank? || user_name.blank?

        params = {
          name: user_name,
          email: email.downcase.strip
        }
        private_user_form = ParticipatorySpacePrivateUserForm.from_params(params, privatable_to:)
                                                             .with_context(
                                                               current_user:,
                                                               current_particiaptory_space: privatable_to
                                                             )

        Decidim::Admin::CreateParticipatorySpacePrivateUser.call(private_user_form, current_user, privatable_to, via_csv: true)
      end
    end
  end
end
