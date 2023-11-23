# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposalState do
        let(:form_klass) { ProposalStateForm }
        let!(:component) { create(:proposal_component) }
        let(:current_organization) { component.organization }
        let(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        let(:form) do
          form_klass.from_params(
            form_params
          ).with_context(
            current_user:,
            current_organization:,
            current_participatory_space: component.participatory_space,
            current_component: component
          )
        end

        subject { described_class.new(form, component) }

        describe "call" do
          let(:form_params) do
            {
              title: { en: "A reasonable proposal title" },
              description: { en: "A reasonable proposal body" },
              token: "custom",
              default: false,
              answerable: false,
              notifiable: false,
              gamified: false
            }
          end

          describe "when the form is not valid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { subject.call }.to broadcast(:invalid)
            end

            it "does not create a proposal state" do
              expect do
                subject.call
              end.not_to change(Decidim::Proposals::ProposalState, :count)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { subject.call }.to broadcast(:ok)
            end

            it "creates a new proposal" do
              expect do
                subject.call
              end.to change(Decidim::Proposals::ProposalState, :count).by(1)
            end
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:create, Decidim::Proposals::ProposalState, kind_of(Decidim::User), {})
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
