# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserReportMailer, type: :mailer do
    let(:organization) { create(:organization, name: "Test Organization") }
    let(:admin) { create(:user, :admin, organization:) }
    let(:reporter) { create(:user, :confirmed, organization:) }
    let(:moderation) { create(:user_moderation, user:) }
    let(:user_report) { create(:user_report, user: reporter, reason:, details: "Lorem ipsum", moderation:) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:reason) { "spam" }

    describe "#notify" do
      let(:mail) { described_class.notify(admin, user_report) }

      describe "email body" do
        it "includes the reported user name" do
          expect(email_body(mail)).to include(user.name)
        end

        it "includes the reporter name" do
          expect(email_body(mail)).to include(reporter.name)
        end

        it "includes the reason" do
          expect(email_body(mail)).to include(I18n.t(reason, scope: "decidim.shared.flag_user_modal"))
        end

        context "when the user is already blocked" do
          let(:user) { create(:user, :blocked, organization:) }

          it "includes the reported user's original name" do
            # The `user.name` is set to "Blocked user"
            expect(email_body(mail)).to include(user.name)
            expect(email_body(mail)).to include(reporter.name)
            expect(email_body(mail)).to include(admin.name)
          end
        end
      end
    end
  end
end
