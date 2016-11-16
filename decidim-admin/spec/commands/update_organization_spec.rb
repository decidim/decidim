# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe UpdateOrganization, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:form) do
          OrganizationForm.from_params(
            organization: organization.attributes.merge(name: "My super organization"),
          )
        end
        let(:command) { described_class.new(organization, form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the organization" do
            command.call
            organization.reload

            expect(organization.name).to_not eq("My super organization")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the organization in the organization" do
            command.call
            organization.reload

            expect(organization.name).to eq("My super organization")
          end
        end
      end
    end
  end
end
