# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReportedMailer, type: :mailer do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, organization: organization) }
    let(:component) { create(:component, organization: organization) }
    let(:reportable) { create(:proposal) }
    let(:moderation) { create(:moderation, reportable: reportable, participatory_space: component.participatory_space, report_count: 1) }
    let!(:report) { create(:report, moderation: moderation, details: "bacon eggs spam") }

    describe "#report" do
      let(:mail) { described_class.report(user, report) }

      describe "localisation" do
        let(:subject) { "Un contingut ha estat denunciat" }
        let(:default_subject) { "A resource has been reported" }

        let(:body) { "ha estat reportat" }
        let(:default_body) { "has been reported" }

        include_examples "localised email"
      end

      describe "email body" do
        it "includes the participatory space name" do
          expect(mail.body.encoded).to match(moderation.participatory_space.title["en"])
        end

        it "includes the report's reason" do
          expect(mail.body.encoded).to match(report.reason)
        end

        it "includes the report's details" do
          expect(mail.body.encoded).to match(report.details)
        end

        it "includes the reported content" do
          expect(mail.body.encoded).to match(reportable.try(:title))
          expect(mail.body.encoded).to match(reportable.try(:body))
        end

        it "includes the name of the author and a link to their profile" do
          link = "profile_path(report.user.nickname)"
          expect(mail.body.encoded).to match("<a href=\"#{link}\">#{report.user.name}</a>")
        end
      end
    end

    describe "#hide" do
      let(:mail) { described_class.hide(user, report) }

      let(:subject) { "Un contingut s'ha ocultat automàticament" }
      let(:default_subject) { "A resource has been hidden automatically" }

      let(:body) { "ocultat automàticament" }
      let(:default_body) { "has been hidden" }

      include_examples "localised email"
    end
  end
end
