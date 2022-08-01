# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe DestroySortition do
        let(:organization) { create(:organization) }
        let(:admin) { create(:user, :admin, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:sortition_component) { create(:sortition_component, participatory_space: participatory_process) }
        let(:sortition) { create(:sortition, component: sortition_component) }
        let(:cancel_reason) do
          Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(word_count: 4) }
        end

        let(:params) do
          {
            id: sortition.id,
            sortition: {
              cancel_reason:
            }
          }
        end

        let(:context) do
          {
            current_component: sortition_component,
            current_user: admin
          }
        end

        let(:form) { DestroySortitionForm.from_params(sortition: params).with_context(context) }
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't cancel the sortition" do
            command.call
            sortition.reload
            expect(sortition).not_to be_cancelled
          end
        end

        describe "when the form is valid" do
          before do
            allow(form).to receive(:invalid?).and_return(false)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "Cancels the sortition" do
            command.call
            sortition.reload
            expect(sortition).to be_cancelled
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:delete, sortition, admin)
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "Data from the user who cancelled the sortition is stored" do
            command.call
            sortition.reload
            expect(sortition.cancelled_by_user).to eq(admin)
          end
        end
      end
    end
  end
end
