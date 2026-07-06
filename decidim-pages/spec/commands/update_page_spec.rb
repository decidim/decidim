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
        let(:page) { create(:page, component:) }
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
            current_organization:
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

          it "does not update the page" do
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

          it "traces the action", versioning: true do
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

        describe "with attachments" do
          let!(:existing_attachment) { create(:attachment, :with_pdf, attached_to: page) }
          let(:form_params) do
            {
              "body" => { "en" => "My new body" },
              "attachments" => [existing_attachment.id.to_s]
            }
          end

          it "keeps existing attachments" do
            command.call
            expect(page.reload.attachments).to include(existing_attachment)
          end

          context "when removing attachments" do
            let(:form_params) do
              {
                "body" => { "en" => "My new body" },
                "attachments" => []
              }
            end

            it "removes attachments not in the list" do
              command.call
              expect(page.reload.attachments).not_to include(existing_attachment)
            end
          end
        end
      end
    end
  end
end
