# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReportedMailer, type: :mailer do
    let(:organization) { create(:organization, name: "Test Organization") }
    let(:user) { create(:user, :admin, organization:) }
    let(:component) { create(:component, organization:) }
    let(:reportable) { create(:proposal, title: Decidim::Faker::Localized.sentence, body: Decidim::Faker::Localized.paragraph(sentence_count: 3)) }
    let(:moderation) { create(:moderation, reportable:, participatory_space: component.participatory_space, report_count: 1) }
    let(:author) { reportable.creator_identity }
    let!(:report) { create(:report, moderation:, details: "bacon eggs spam") }
    let(:decidim) { Decidim::Core::Engine.routes.url_helpers }

    describe "#report" do
      let(:mail) { described_class.report(user, report) }

      describe "localisation" do
        let(:mail_subject) { "Un contingut ha estat denunciat" }
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
          expect(email_body(mail)).to match("(ID: #{reportable.id})")
          expect(email_body(mail)).to match(reportable.title["en"])
          expect(email_body(mail)).to match(reportable.body["en"])
        end

        it "renders the organization default language when the content language cannot be deduced by the reported content itself" do
          report.moderation.reportable.title = nil
          report.moderation.reportable.body = nil

          expect(email_body(mail)).to match("<b>Content original language</b>")
          expect(email_body(mail)).to match("English")
        end

        it "includes the content original language when only one language is present" do
          report.moderation.reportable.title = { "ca" => "title", "machine_translations" => { "fi" => "title", "se" => "title" } }

          expect(email_body(mail)).to match("<b>Content original language</b>")
          expect(email_body(mail)).to match(I18n.t("locale.name", locale: "ca"))
        end

        it "includes the content original language as the organization's default when the content has more than one language" do
          report.moderation.reportable.title = { "ca" => "title", "fi" => "title", "se" => "title" }

          expect(email_body(mail)).to match("<b>Content original language</b>")
          expect(email_body(mail)).to match(I18n.t("locale.name", locale: organization.default_locale))
        end

        context "when the author is a user" do
          it "includes the name of the author and a link to their profile" do
            expect(mail).to have_link(author.name, href: decidim.profile_url(author.nickname, host: organization.host))
          end
        end

        context "when the author is a deleted user" do
          before do
            author.nickname = ""
            author.deleted_at = 1.week.ago
            author.save!
          end

          it "includes the name of the author but no link to their profile" do
            expect(mail).not_to have_link(author.name)
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

        context "when the author is a meeting" do
          let(:meetings_component) { create :component, manifest_name: :meetings, organization: reportable.organization }
          let!(:meeting) { create :meeting, component: meetings_component }

          it "includes the title of the meeting" do
            reportable.coauthorships.destroy_all
            create :coauthorship, coauthorable: reportable, author: meeting

            expect(email_body(mail)).to match(translated(meeting.title))
          end
        end
      end
    end

    describe "#hide" do
      let(:mail) { described_class.hide(user, report) }

      let(:mail_subject) { "Un contingut s'ha ocultat automàticament" }
      let(:default_subject) { "A resource has been hidden automatically" }

      let(:body) { "ocultat automàticament" }
      let(:default_body) { "has been hidden" }

      include_examples "localised email"
    end
  end
end
