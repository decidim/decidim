# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    module Admin
      describe UpdatePage do
        let(:current_organization) { create(:organization) }
        let(:user) { create(:user, organization: current_organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:component) { create(:component, manifest_name: "pages", participatory_space: participatory_process) }
        let(:page) { create(:page, component: component) }
        let(:form_params) do
          {
            "body" => { "en" => "My new body" }
          }
        end
        let(:form) do
          PageForm.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: current_organization
          )
        end
        let(:command) { described_class.new(form, page) }

        describe "when the form is invalid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the page" do
            expect(page).not_to receive(:update!)
            command.call
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new page with the same name as the component" do
            expect(page).to receive(:update!)
            command.call
          end

          it "traces tyhe action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(page, user, body: form.body)
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "update"
          end
        end
      end
    end
  end
end
