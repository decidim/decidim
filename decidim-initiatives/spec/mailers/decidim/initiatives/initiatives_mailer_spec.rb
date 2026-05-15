# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesMailer do
      include Decidim::TranslationsHelper

      let(:organization) { create(:organization, host: "1.lvh.me") }
      let(:initiative) { create(:initiative, organization:) }
      let(:router) { Decidim::Initiatives::Engine.routes.url_helpers }
      let(:admin_router) { Decidim::Initiatives::AdminEngine.routes.url_helpers }

      context "when notifies creation" do
        let(:mail) { described_class.notify_creation(initiative) }

        context "when the promoting committee is enabled" do
          it "renders the headers" do
            expect(mail.subject).to eq("Your initiative '#{translated(initiative.title)}' has been created")
            expect(mail.to).to eq([initiative.author.email])
          end

          it "renders the body" do
            expect(mail.body.encoded).to include(decidim_escape_translated(initiative.title))
          end

          it "renders the promoter committee help" do
            expect(mail.body).to match("Forward the following link to invite people to the promoter committee")
          end
        end

        context "when the promoting committee is disabled" do
          let(:organization) { create(:organization) }
          let(:initiatives_type) { create(:initiatives_type, organization:, promoting_committee_enabled: false) }
          let(:scoped_type) { create(:initiatives_type_scope, type: initiatives_type) }
          let(:initiative) { create(:initiative, organization:, scoped_type:) }

          it "renders the headers" do
            expect(mail.subject).to eq("Your initiative '#{translated(initiative.title)}' has been created")
            expect(mail.to).to eq([initiative.author.email])
          end

          it "renders the body" do
            expect(mail.body.encoded).to include(decidim_html_escape(translated(initiative.title)))
          end

          it "does not render the promoter committee help" do
            expect(mail.body).not_to match("Forward the following link to invite people to the promoter committee")
          end
        end

        it "renders the correct link" do
          expect(mail).to have_link(router.initiative_url(initiative, locale: I18n.locale, host: initiative.organization.host))
          expect(mail).to have_no_link(admin_router.initiative_url(initiative, host: initiative.organization.host))
        end
      end

      context "when notifies state change" do
        let(:mail) { described_class.notify_state_change(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("The initiative #{translated(initiative.title)} has changed its status")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body).to include("The initiative #{decidim_sanitize_translated(initiative.title)} has changed its status to: #{I18n.t(initiative.state, scope: "decidim.initiatives.admin_states")}")
        end
      end

      context "when notifies progress" do
        let(:mail) { described_class.notify_progress(initiative, initiative.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("Summary about the initiative: #{translated(initiative.title)}")
          expect(mail.to).to eq([initiative.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to include(decidim_sanitize_translated(initiative.title))
        end
      end
    end
  end
end
