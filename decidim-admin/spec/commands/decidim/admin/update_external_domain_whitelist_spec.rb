# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateExternalDomainWhitelist do
    let(:organization) { create(:organization, external_domain_whitelist: []) }
    let(:user) { create(:user, organization: organization) }
    let(:form) { Decidim::Admin::OrganizationExternalDomainWhitelistForm.from_params(attributes) }
    let(:command) { described_class.new(form, organization, user) }
    let(:domains) { ["erabaki.pamplona.es", "osallistu.hel.fi", "codefor.fr"] }
    let(:attributes) do
      {
        external_domains: {
          "1613404734167" => { "value" => domains[0], "id" => "", "position" => "0", "deleted" => "false" },
          "1613404734172" => { "value" => domains[1], "id" => "", "position" => "1", "deleted" => "false" },
          "1613404734961" => { "value" => domains[2], "id" => "", "position" => "2", "deleted" => "false" }
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
        expect(organization.external_domain_whitelist).to include(domains[0])
        expect(organization.external_domain_whitelist).to include(domains[1])
        expect(organization.external_domain_whitelist).to include(domains[2])
        expect(organization.external_domain_whitelist.length).to eq(3)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("update_external_domain", organization, user)
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("update_external_domain")
        expect(action_log.version).to be_present
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
