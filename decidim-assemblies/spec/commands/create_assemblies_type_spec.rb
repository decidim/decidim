# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssembliesType do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:form) do
      instance_double(
        Admin::AssembliesTypeForm,
        invalid?: invalid,
        title: { en: "title" },
        current_organization: organization
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

      it "creates a new assembly type for the organization" do
        expect { subject.call }.to change { Decidim::AssembliesType.count }.by(1)
      end
    end
  end
end
