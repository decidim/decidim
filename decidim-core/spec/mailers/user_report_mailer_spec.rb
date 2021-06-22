# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserReportMailer, type: :mailer do
    let(:organization) { create(:organization, name: "Test Organization") }
    let(:admin) { create(:user, :admin, organization: organization) }
    let(:reporter) { create(:user, :confirmed, organization: organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:reason) { "spam" }

    describe "#notify" do
      let(:mail) { described_class.notify(admin, reporter, reason, user) }

      describe "email body" do
        it "includes the reported user name" do
          expect(email_body(mail)).to include(user.name)
        end

        it "includes the reporter name" do
          expect(email_body(mail)).to include(reporter.name)
        end

        it "includes the reason" do
          expect(email_body(mail)).to include(reason)
        end

        context "when the user is already blocked" do
          let(:user) { create(:user, :blocked, organization: organization) }

          it "includes the reported user's original name" do
            # The `user.name` is set to "Blocked user"
            expect(email_body(mail)).not_to include(user.name)
            expect(email_body(mail)).to include(user.user_name)
          end
        end
      end
    end
  end
end
