# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesMailer, type: :mailer do
      let(:organization) { create(:organization, host: "1.lvh.me") }
      let(:initiative) { create(:initiative, organization: organization) }
      let(:router) { Decidim::Initiatives::Engine.routes.url_helpers }
      let(:admin_router) { Decidim::Initiatives::AdminEngine.routes.url_helpers }

      context "when notifies creation" do
        let(:mail) { described_class.notify_creation(initiative) }

        it "renders the headers" do
          expect(mail.subject).to eq("Your initiative '#{initiative.title["en"]}' has been created")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(initiative.title["en"])
        end

        it "renders the correct link" do
          expect(mail).to have_link(router.initiative_url(initiative, host: initiative.organization.host))
          expect(mail).not_to have_link(admin_router.initiative_url(initiative, host: initiative.organization.host))
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
