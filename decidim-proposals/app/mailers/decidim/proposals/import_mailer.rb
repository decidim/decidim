# frozen_string_literal: true

module Decidim
  module Proposals
    class ImportMailer < Decidim::ApplicationMailer
      def proposals_imported(collection, user)
        setup_import_context(collection, user)

        with_user(user) do
          mail(
            to: user.email,
            subject: I18n.t(
              "decidim.events.proposals.proposals_imported.email_subject",
              participatory_space_title: @participatory_space_title
            )
          )
        end
      end

      def proposal_answers_imported(collection, user)
        setup_import_context(collection, user)

        with_user(user) do
          mail(
            to: user.email,
            subject: I18n.t(
              "decidim.events.proposals.proposals_answers_imported.email_subject",
              participatory_space_title: @participatory_space_title
            )
          )
        end
      end

      private

      def setup_import_context(collection, user)
        @organization = user.organization
        @user = user
        first = collection.first
        return if first.blank?

        @participatory_space_title = decidim_sanitize_translated(first.participatory_space.title)
        @component_url = Decidim::EngineRouter.main_proxy(first.component).root_url
      end
    end
  end
end
