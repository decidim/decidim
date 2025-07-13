# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ImportProposalsMailer < Decidim::ApplicationMailer
        def notify_success(user, origin_component, target_component, count)
          @organization = user.organization
          @origin_component = origin_component
          @target_component = target_component
          @count = count

          with_user(user) do
            mail(to: user.email, subject: t(".subject"))
          end
        end

        def notify_failure(user, origin_component, target_component)
          @organization = user.organization
          @origin_component = origin_component
          @target_component = target_component

          with_user(user) do
            mail(to: user.email, subject: t(".subject"))
          end
        end
      end
    end
  end
end
