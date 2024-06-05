# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals::Admin
  describe ProposalsValuatorMailer, type: :mailer do
    include ActionView::Helpers::SanitizeHelper

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }
    let(:user) { create(:user, organization: organization, name: "Tamilla", email: "valuator@example.org") }
    let(:admin) { create(:user, :admin, organization: organization, name: "Mark") }
    let(:proposals) { create_list(:proposal, 3, component: proposals_component) }

    def proposal_url(proposal)
      Decidim::ResourceLocatorPresenter.new(proposal).url
    end

    context "when valuator assigned" do
      let(:mail) { described_class.notify_proposals_valuator(user, admin, proposals) }

      it "set subject email" do
        expect(mail.subject).to eq("New proposals assigned to you for evaluation")
      end

      it "set email from" do
        expect(mail.from).to eq([Decidim::Organization.first.smtp_settings["from"]])
      end

      it "set email to" do
        expect(mail.to).to eq(["valuator@example.org"])
      end

      it "body email has valuator name" do
        expect(email_body(mail)).to include("Tamilla")
      end

      it "body email has proposal links" do
        body = email_body(mail)
        expect(body).to have_link(href: proposal_url(proposals.first))
        expect(body).to have_link(href: proposal_url(proposals.second))
        expect(body).to have_link(href: proposal_url(proposals.third))
        expect(body).to have_link(href: Decidim::ResourceLocatorPresenter.new(proposals.first).admin_url)
        expect(body).to have_link(href: Decidim::ResourceLocatorPresenter.new(proposals.second).admin_url)
        expect(body).to have_link(href: Decidim::ResourceLocatorPresenter.new(proposals.third).admin_url)
      end
    end
  end
end
