# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateOrganization do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:params) do
        {
          organization: {
            name: "My super organization",
            reference_prefix: "MSO",
            default_locale: "en"
          }
        }
      end
      let(:context) do
        { current_organization: organization }
      end
      let(:form) do
        OrganizationForm.from_params(params).with_context(context)
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

          expect(organization.name).not_to eq("My super organization")
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the organization in the organization" do
          expect { command.call }.to broadcast(:ok)
          organization.reload

          expect(organization.name).to eq("My super organization")
        end
      end
    end
  end
end
