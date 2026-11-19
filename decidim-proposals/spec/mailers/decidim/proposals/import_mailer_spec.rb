# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ImportMailer do
    let(:organization) { create(:organization, default_locale: "en", available_locales: %w(en ca)) }
    let(:participatory_process) do
      create(:participatory_process, organization:, title: { "en" => "English space", "ca" => "Espai en català" })
    end
    let(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:proposal) { create(:proposal, component:) }
    let(:user) { create(:user, :confirmed, organization:, locale: "ca") }

    shared_examples "localised import email" do
      it "uses the recipient locale for the participatory space title" do
        I18n.with_locale(:en) do
          expect(mail.subject).to include("Espai en català")
          expect(mail.body.encoded).to include("Espai en català")
          expect(mail.subject).not_to include("English space")
        end
      end
    end

    describe "#proposals_imported" do
      let(:mail) { described_class.proposals_imported(proposal, user) }

      it_behaves_like "localised import email"
    end

    describe "#proposal_answers_imported" do
      let(:mail) { described_class.proposal_answers_imported(proposal, user) }

      it_behaves_like "localised import email"
    end
  end
end
