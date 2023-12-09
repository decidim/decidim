# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe UpdateProposalAnswerTemplate do
        subject { described_class.new(template, form, user) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:template) { create(:template, :proposal_answer, organization:) }
        let!(:component_constraint) { 0 }
        let(:name) { { "en" => "name" } }
        let(:description) { { "en" => "description" } }
        let(:internal_state) { "accepted" }

        let(:form) do
          instance_double(
            ProposalAnswerTemplateForm,
            invalid?: invalid,
            valid?: !invalid,
            current_user: user,
            current_organization: organization,
            name:,
            description:,
            internal_state:,
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

          context "when changing the internal state" do
            context "with rejected" do
              let(:internal_state) { "rejected" }

              it "saves the internal state" do
                subject.call
                expect(template.reload.field_values["internal_state"]).to eq(internal_state)
              end
            end

            context "with accepted" do
              let(:internal_state) { "accepted" }

              it "saves the internal state" do
                subject.call
                expect(template.reload.field_values["internal_state"]).to eq(internal_state)
              end
            end

            context "with evaluating" do
              let(:internal_state) { "evaluating" }

              it "saves the internal state" do
                subject.call
                expect(template.reload.field_values["internal_state"]).to eq(internal_state)
              end
            end

            context "with not_answered" do
              let(:internal_state) { "not_answered" }

              it "saves the internal state" do
                subject.call
                expect(template.reload.field_values["internal_state"]).to eq(internal_state)
              end
            end
          end

          context "when the form has a component constraint" do
            context "and templatable is Organization" do
              it "creates the second resource" do
                expect { subject.call }.to broadcast(:ok)
                expect(template.reload.templatable).to eq(organization)
              end
            end

            context "and templatable is Proposal Component" do
              let(:component) { create(:component, manifest_name: :proposals, organization:) }
              let(:component_constraint) { component.id }

              it "creates the second resource" do
                expect(template.reload.templatable).to eq(organization)
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
