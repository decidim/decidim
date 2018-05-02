# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesMailer, type: :mailer do
      let(:initiative) { create(:initiative) }

      context "when notifies creation" do
        let(:mail) { InitiativesMailer.notify_creation(initiative) }

        it "renders the headers" do
          expect(mail.subject).to eq("Your citizen initiative '#{initiative.title["en"]}' has been created")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end
      end

      context "when notifies state change" do
        let(:mail) { InitiativesMailer.notify_state_change(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("The initiative #{initiative.title["en"]} has changed its state")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end
      end

      context "when notifies validating request" do
        let(:mail) { InitiativesMailer.notify_validating_request(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("The initiative #{initiative.title["en"]} has requested its technical validation.")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end
      end

      context "when notifies progress" do
        let(:mail) { InitiativesMailer.notify_progress(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("Resume about the initiative: #{initiative.title["en"]}")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end
      end
    end
  end
end
