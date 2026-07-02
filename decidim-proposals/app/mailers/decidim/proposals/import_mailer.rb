# frozen_string_literal: true

module Decidim
  module Proposals
    class ImportMailer < Decidim::ApplicationMailer
      include Decidim::SanitizeHelper
      include Decidim::ComponentPathHelper

      layout "decidim/mailer"

      def proposals_imported(collection, user)
        @organization = user.organization
        @user = user
        first = collection.first
        @participatory_space_title = decidim_sanitize_translated(first.participatory_space.title) if first.present?
        @component_url = Decidim::EngineRouter.main_proxy(first.component).root_url if first.present?
        I18n.locale = user.locale if user.locale.present?

        subject = I18n.t("decidim.events.proposals.proposals_imported.email_subject", participatory_space_title: @participatory_space_title)
        mail(to: user.email, subject:)
      end

      def proposal_answers_imported(collection, user)
        @organization = user.organization
        @user = user
        first = collection.first
        @participatory_space_title = decidim_sanitize_translated(first.participatory_space.title) if first.present?
        @component_url = Decidim::EngineRouter.main_proxy(first.component).root_url if first.present?
        I18n.locale = user.locale if user.locale.present?

        subject = I18n.t("decidim.events.proposals.proposals_answers_imported.email_subject", participatory_space_title: @participatory_space_title)
        mail(to: user.email, subject:)
      end
    end
  end
end