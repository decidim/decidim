# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::UpdateAssembliesType do
    subject { described_class.new(assembly_type, form) }

    let(:organization) { create :organization }
    let(:assembly_type) { create :assemblies_type, organization: organization }
    let(:title) { Decidim::Faker::Localized.literal("New title") }
    let(:form) do
      double(
        invalid?: invalid,
        title: title
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
      before do
        subject.call
        assembly_type.reload
      end

      it "updates the title of the assembly_type" do
        expect(translated(assembly_type.title)).to eq("New title")
      end
    end
  end
end
