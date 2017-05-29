# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe UpdateOrganization, :db do
      describe "call" do
        let(:form) do
          UpdateOrganizationForm.new(params)
        end
        let(:organization) { create :organization, name: "My organization" }

        let(:command) { described_class.new(organization.id, form) }

        context "when the form is valid" do
          let(:params) do
            {
              name: "Gotham City",
              host: "decide.gotham.gov",
              secondary_hosts: "foo.gotham.gov\r\n\r\nbar.gotham.gov"
            }
          end

          it "returns a valid response" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the organization" do
            expect { command.call }.to change { Organization.count }.by(1)
            organization = Organization.last

            expect(organization.name).to eq("Gotham City")
            expect(organization.host).to eq("decide.gotham.gov")
            expect(organization.secondary_hosts).to match_array(["foo.gotham.gov", "bar.gotham.gov"])
          end
        end

        context "when the form is invalid" do
          let(:params) do
            {
              name: nil,
              host: "foo.com"
            }
          end

          it "returns an invalid response" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
