# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyParticipatoryProcess do
    subject { assembly_participatory_process }

    let(:organization) { create :organization }
    let(:assembly) { create :assembly, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:assembly_participatory_process) { create :assembly_participatory_process, assembly: assembly, participatory_process: participatory_process }

    it { is_expected.to be_valid }

    context "when there's an exisiting related participatory process with the same assembly and same participatory process" do
      let(:assembly_participatory_process) do
        build(
          :assembly_participatory_process,
          assembly: existing_assembly_participatory_process.assembly,
          participatory_process: existing_assembly_participatory_process.participatory_process
        )
      end

      let!(:existing_assembly_participatory_process) do
        create(:assembly_participatory_process)
      end

      it { is_expected.not_to be_valid  }
    end

    context "when there's an existing related participatory process with the same assembly and diferent process" do
      let(:assembly_participatory_process) do
        build(
          :assembly_participatory_process,
          assembly: existing_assembly_participatory_process.assembly,
        )
      end

      let!(:existing_assembly_participatory_process) do
        create(:assembly_participatory_process)
      end

      it { is_expected.to be_valid }
    end
  end
end
