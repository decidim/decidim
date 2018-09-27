require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ImportParticipatoryText do
        describe "call" do
          let!(:document_file) { Decidim::Dev.asset("participatory_text.md") }
          let(:current_component) do
            create(
              :component,
              participatory_space: create(:participatory_process)
            )
          end
          let(:form) do
            instance_double(
              ImportParticipatoryTextForm,
              current_component: current_component,
              title: {},
              valid?: valid
            )
          end
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create any proposal" do
              expect do
                command.call
              end.to change(Proposal, :count).by(0)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok and creates the proposals" do
              expect { command.call }.to (
                broadcast(:ok) &&
                change { Proposal.where(component: current_component).count }.by(1)
              )
            end
          end
        end
      end
    end
  end
end
