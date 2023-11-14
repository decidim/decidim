# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe CreateProposalAnswerTemplate do
        subject { described_class.new(form) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:component_constraint) { 0 }
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

          it "creates a new template for the organization" do
            expect { subject.call }.to change(Decidim::Templates::Template, :count).by(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:create, Decidim::Templates::Template, user, {})
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "creates the second resource" do
            expect(Decidim::Templates::Template.where(target: :proposal_answer).count).to eq(0)
            expect { subject.call }.to broadcast(:ok)
            expect(Decidim::Templates::Template.where(target: :proposal_answer).count).to eq(1)
          end

          context "when changing the internal state" do
            context "when rejected" do
              let(:internal_state) { "rejected" }

              it "saves the internal state" do
                subject.call
                expect(Decidim::Templates::Template.where(target: :proposal_answer).last.field_values["internal_state"]).to eq(internal_state)
              end
            end

            context "when accepted" do
              let(:internal_state) { "accepted" }

              it "saves the internal state" do
                subject.call
                expect(Decidim::Templates::Template.where(target: :proposal_answer).last.field_values["internal_state"]).to eq(internal_state)
              end
            end

            context "when evaluating" do
              let(:internal_state) { "evaluating" }

              it "saves the internal state" do
                subject.call
                expect(Decidim::Templates::Template.where(target: :proposal_answer).last.field_values["internal_state"]).to eq(internal_state)
              end
            end

            context "when not_answered" do
              let(:internal_state) { "not_answered" }

              it "saves the internal state" do
                subject.call
                expect(Decidim::Templates::Template.where(target: :proposal_answer).last.field_values["internal_state"]).to eq(internal_state)
              end
            end
          end

          context "when the form has a component constraint" do
            context "when templatable is Organization" do
              it "creates the second resource" do
                expect(Decidim::Templates::Template.where(target: :proposal_answer).count).to eq(0)
                expect { subject.call }.to broadcast(:ok)
                expect(Decidim::Templates::Template.where(target: :proposal_answer).last.templatable).to eq(organization)
              end
            end

            context "when templatable is Proposal Component" do
              let(:component) { create(:proposal_component, organization:) }
              let(:component_constraint) { component.id }

              it "creates the second resource" do
                expect(Decidim::Templates::Template.where(target: :proposal_answer).count).to eq(0)
                expect { subject.call }.to broadcast(:ok)
                expect(Decidim::Templates::Template.where(target: :proposal_answer).last.templatable).to eq(component)
              end
            end
          end
        end
      end
    end
  end
end
