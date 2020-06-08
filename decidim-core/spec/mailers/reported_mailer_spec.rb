# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReportedMailer, type: :mailer do
    let(:organization) { create(:organization, name: "Test Organization") }
    let(:user) { create(:user, :admin, organization: organization) }
    let(:component) { create(:component, organization: organization) }
    let(:reportable) { create(:proposal, title: Decidim::Faker::Localized.sentence, body: Decidim::Faker::Localized.paragraph(3)) }
    let(:moderation) { create(:moderation, reportable: reportable, participatory_space: component.participatory_space, report_count: 1) }
    let(:author) { reportable.creator_identity }
    let!(:report) { create(:report, moderation: moderation, details: "bacon eggs spam") }
    let(:decidim) { Decidim::Core::Engine.routes.url_helpers }

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
          expect(email_body(mail)).to match(moderation.participatory_space.title["en"])
        end

        it "includes the report's reason" do
          expect(email_body(mail)).to match(I18n.t(report.reason, scope: "decidim.shared.flag_modal"))
        end

        it "includes the report's details" do
          expect(email_body(mail)).to match(report.details)
        end

        it "doesn't include the report details if they are not present" do
          report.details = nil

          expect(email_body(mail)).not_to match("<b>Details</b>")
        end

        it "includes the creation date of the report" do
          expect(email_body(mail)).to match(I18n.l(report.created_at, format: :short))
        end

        it "includes the reported content" do
          expect(email_body(mail)).to match(reportable.title["en"])
          expect(email_body(mail)).to match(reportable.body["en"])
        end

        it "doesn't include the reported content if it's not present" do
          reportable.title = nil
          reportable.body = nil

          expect(email_body(mail)).not_to match("<b>Content</b>")
        end

        context "when the author is a user" do
          it "includes the name of the author and a link to their profile" do
            expect(mail).to have_link(author.name, href: decidim.profile_url(author.nickname, host: organization.host))
          end
        end

        context "when the author is a user group" do
          let(:reportable) { create(:proposal, user_groups: create(:user_group)) }

          it "includes the name of the group and a link to their profile" do
            expect(mail).to have_link(author.name, href: decidim.profile_url(author.nickname, host: organization.host))
          end
        end

        context "when the author is an organization" do
          let(:reportable) { create(:proposal, :official) }

          it "includes the name of the organization" do
            expect(email_body(mail)).to match(author.name)
          end
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
