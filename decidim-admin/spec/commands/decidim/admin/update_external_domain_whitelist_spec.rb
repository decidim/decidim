# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateExternalDomainWhitelist do
    let(:organization) { create(:organization, external_domain_whitelist: []) }
    let(:form) { Decidim::Admin::OrganizationExternalDomainWhitelistForm.from_params(attributes) }
    let(:command) { described_class.new(form, organization) }
    let(:attributes) do
      {
        "external_domains": {
          "1613404734167" => { "value" => "decidim.org", "id" => "", "position" => "0", "deleted" => "false" },
          "1613404734172" => { "value" => "example.org", "id" => "", "position" => "1", "deleted" => "false" },
          "1613404734961" => { "value" => "github.com", "id" => "", "position" => "2", "deleted" => "false" }
        }
      }
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "adds domains to whitelist" do
        expect do
          command.call
        end.to change(organization, :external_domain_whitelist)
        expect(organization.external_domain_whitelist).to include("decidim.org")
        expect(organization.external_domain_whitelist).to include("example.org")
        expect(organization.external_domain_whitelist).to include("github.com")
        expect(organization.external_domain_whitelist.length).to eq(3)
      end
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create an attachment collection" do
        expect do
          command.call
        end.not_to change(organization, :external_domain_whitelist)
      end
    end
  end
end
