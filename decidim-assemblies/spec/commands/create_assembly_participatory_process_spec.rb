# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssemblyParticipatoryProcess do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:assembly) { create :assembly, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }

    let(:errors) { double.as_null_object }

    let(:form) do
      instance_double(
        Admin::AssemblyParticipatoryProcessForm,
        invalid?: invalid,
        assembly: assembly,
        participatory_process: participatory_process,
        errors: errors
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates an assembly participatory_process" do
        expect { subject.call }.to change { Decidim::AssemblyParticipatoryProcess.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end
