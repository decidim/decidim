# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::UpdateAssembliesSetting do
    subject { described_class.new(assembly_setting, form) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:assembly_setting) { create :assemblies_setting, organization: }
    let(:enable_organization_chart) { true }
    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        enable_organization_chart:
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

      it "updates the assemblies settings" do
        expect(assembly_setting.enable_organization_chart).to be_truthy
      end
    end
  end
end
