# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyParticipatoryProcessForm do
        subject { described_class.from_params(attributes) }

        let(:organization) { create :organization }
        let(:assembly) { create :assembly, organization: organization }
        let(:participatory_process) { create :participatory_process, organization: organization }

        let(:attributes) do
          {
            "assembly_participatory_process" => {
              "assembly_id" => assembly.try(:id),
              "participatory_process_id" => participatory_process.try(:id)
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when participatory_process is missing" do
          let(:participatory_process) {}

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
