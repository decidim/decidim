# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesMailer, type: :mailer do
      let(:initiative) { create(:initiative) }

      context "when notifies creation" do
        let(:mail) { described_class.notify_creation(initiative) }

        it "renders the headers" do
          expect(mail.subject).to eq("Your initiative '#{initiative.title["en"]}' has been created")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end
      end

      context "when notifies state change" do
        let(:mail) { described_class.notify_state_change(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("The initiative #{initiative.title["en"]} has changed its status")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body).to match("The initiative #{initiative.title["en"]} has changed its status to: #{I18n.t(initiative.state, scope: "decidim.initiatives.admin_states")}")
        end
      end

      context "when notifies progress" do
        let(:mail) { described_class.notify_progress(initiative, initiative.author) }

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
