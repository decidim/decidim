# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesMailer, type: :mailer do
      let(:initiative) { create(:initiative) }

      context "when notifies creation" do
        let(:mail) { InitiativesMailer.notify_creation(initiative) }

        context "when the promoting committee is enabled" do
          it "renders the headers" do
            expect(mail.subject).to eq("Your initiative '#{initiative.title["en"]}' has been created")
            expect(mail.to).to eq([initiative.author.email])
          end

          it "renders the body" do
            expect(mail.body.encoded).to match(initiative.title["en"])
          end

          it "renders the promoter committee help" do
            expect(mail.body).to match("Forward the following link to invite people to the promoter committee")
          end
        end

        context "when the promoting committee is disabled" do
          let(:organization) { create(:organization) }
          let(:initiatives_type) { create(:initiatives_type, organization: organization, promoting_committee_enabled: false) }
          let(:scoped_type) { create(:initiatives_type_scope, type: initiatives_type) }
          let(:initiative) { create(:initiative, organization: organization, scoped_type: scoped_type) }

          it "renders the headers" do
            expect(mail.subject).to eq("Your initiative '#{initiative.title["en"]}' has been created")
            expect(mail.to).to eq([initiative.author.email])
          end

          it "renders the body" do
            expect(mail.body.encoded).to match(initiative.title["en"])
          end

          it "doesn't render the promoter committee help" do
            expect(mail.body).not_to match("Forward the following link to invite people to the promoter committee")
          end
        end
      end

      context "when notifies state change" do
        let(:mail) { InitiativesMailer.notify_state_change(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("The initiative #{initiative.title["en"]} has changed its status")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body).to match("The initiative #{initiative.title["en"]} has changed its status to: #{I18n.t(initiative.state, scope: "decidim.initiatives.admin_states")}")
        end
      end

      context "when notifies progress" do
        let(:mail) { InitiativesMailer.notify_progress(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("Summary about the initiative: #{initiative.title["en"]}")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end
      end
    end
  end
end
