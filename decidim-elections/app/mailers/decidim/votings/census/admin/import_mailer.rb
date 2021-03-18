# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # This mailer sends a notification email containing the result of importing a
        # census dataset into datum.
        class ImportMailer < Decidim::ApplicationMailer
          def import(user, errors)
            @user = user
            @organization = user.organization
            @errors = errors

            with_user(user) do
              mail(to: "#{user.name} <#{user.email}>", subject: "Imported csv dataset")
            end
          end
        end
      end
    end
  end
end
