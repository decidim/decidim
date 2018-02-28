# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::UpdateAssemblyParticipatoryProcess do
    describe "call" do
      let(:organization) { create :organization }
      let(:assembly) { create :assembly, organization: organization }
      let(:participatory_process) { create :participatory_process, organization: organization }

      let(:participatory_process_other) { create :participatory_process, organization: organization }

      let(:assembly_participatory_process) { create :assembly_participatory_process, assembly: assembly, participatory_process: participatory_process_other }

      let(:params) do
        {
          assembly_participatory_process: {
            id: assembly_participatory_process.id,
            assembly_id: assembly.id,
            participatory_process_id: participatory_process.id
          }
        }
      end

      let(:form) do
        Admin::AssemblyParticipatoryProcessForm.from_params(params)
      end

      let(:command) { described_class.new(assembly_participatory_process, form) }

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the assembly participatory process" do
          command.call
          assembly_participatory_process.reload

          expect(assembly_participatory_process.participatory_process.id).not_to eq(participatory_process.id)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the assembly participatory process" do
          expect { command.call }.to broadcast(:ok)
          
          expect(assembly_participatory_process.participatory_process.title).to eq(participatory_process.title)
        end
      end
    end
  end
end
