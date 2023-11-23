# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe DestroyProposalState do
        subject { described_class.new(state, user) }
        let!(:component) { create(:proposal_component) }
        let(:current_organization) { component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization: current_organization) }
        let(:state_params) do
          {
            title: { "en" => "Editable state" },
            description: { "en" => "Editable description" },
            announcement_title: { "en" => "Editable announcement title" },
            token: "editable",
            css_class: "csseditable",
            default: false,
            answerable: false,
            notifiable: false,
            gamified: false,
            system: false
          }
        end
        let!(:state) { create(:proposal_state, component:, **state_params) }

        context "when everything is ok" do
          it "destroys the result" do
            subject.call
            expect { state.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:delete, state, user)
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
