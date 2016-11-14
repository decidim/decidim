# frozen_string_literal: true
require "spec_helper"

module Decidim
  module System
    describe RegisterOrganization, :db do
      describe "call" do
        let(:form) do
          RegisterOrganizationForm.new(params)
        end

        let(:command) { described_class.new(form) }

        context "when the form is valid" do
          let(:params) do
            {
              name: "Gotham City",
              host: "decide.gotham.gov",
              description_en: "Fictional city appearing in American comic books.",
              organization_admin_name: "Fiorello Henry La Guardia",
              organization_admin_email: "f.laguardia@gotham.gov"
            }
          end

          it "returns a valid response" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new organization" do
            expect { command.call }.to change { Organization.count }.by(1)
            organization = Organization.last

            expect(organization.name).to eq("Gotham City")
            expect(organization.host).to eq("decide.gotham.gov")
          end

          it "invites a user as organization admin" do
            expect { command.call }.to change { User.count }.by(1)
            admin = User.last

            expect(admin.email).to eq("f.laguardia@gotham.gov")
            expect(admin.organization.name).to eq("Gotham City")
            expect(admin.organization.description).to include("en" => "Fictional city appearing in American comic books.")
            expect(admin.roles).to include("admin")
            expect(admin).to be_created_by_invite
          end

          it "sends a custom email", perform_enqueued: true do
            expect { command.call }.to change { emails.count }.by(1)
            expect(last_email_body).to include(URI.encode_www_form(["/admin"]))
          end

          it "creates the default content pages for the organization" do
            command.call
            organization = Organization.last
            expect(organization.static_pages.count).to eq(Decidim::StaticPage::DEFAULT_PAGES.length)
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
