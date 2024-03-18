# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe UpdateProposalAnswerTemplate do
        subject { described_class.new(template, form, user) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:template) { create(:template, target: :proposal_answer, organization:) }
        let!(:component_constraint) { 0 }
        let(:name) { { "en" => "name" } }
        let(:description) { { "en" => "description" } }

        let!(:proposal_state_id) { rand(1..10) }

        let(:form) do
          instance_double(
            ProposalAnswerTemplateForm,
            invalid?: invalid,
            valid?: !invalid,
            current_user: user,
            current_organization: organization,
            name:,
            description:,
            proposal_state_id:,
            component_constraint:
          )
        end

        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "updates the template" do
            subject.call
            expect(template.name).to eq(name)
            expect(template.description).to eq(description)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:update, template, user, {})
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "saves the proposal_state_id" do
            subject.call
            expect(template.reload.field_values["proposal_state_id"]).to eq(proposal_state_id)
          end

          context "when the form has a component constraint" do
            context "and templatable is Proposal Component" do
              let(:component) { create(:component, manifest_name: :proposals, organization:) }
              let(:component_constraint) { component.id }

              it "creates the second resource" do
                expect { subject.call }.to broadcast(:ok)
                expect(template.reload.templatable).to eq(component)
              end
            end
          end
        end
      end
    end
  end
end
