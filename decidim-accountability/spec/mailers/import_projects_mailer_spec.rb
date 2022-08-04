# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe ImportProjectsMailer, type: :mailer do
      let(:user) { create :user, organization: }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      # def import(user)
      #   @user = user
      #   @organization = user.organization

      #   with_user(user) do
      #     mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.accountability.import_projects_mailer.import.subject"))
      #   end
      # end
      context "with a valid user" do
        let(:mail) { described_class.import(user) }

        it "emails success message to the user" do
          expect(mail.body).to include(I18n.t("decidim.accountability.import_projects_mailer.import.success"))
        end
      end
    end
  end
end
