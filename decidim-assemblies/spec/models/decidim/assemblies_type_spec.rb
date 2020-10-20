# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssembliesType do
    subject(:assemblies_type) { build(:assemblies_type) }

    it { is_expected.to be_valid }

    context "without title" do
      subject(:assemblies_type) { build(:assemblies_type, title: { en: "My title" }) }

      before do
        assemblies_type.title = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        assemblies_type.organization = nil
      end

      it { is_expected.to be_invalid }
    end

    describe "has an association for children assemblies" do
      subject(:children) { assemblies_type.assemblies }

      let(:assemblies) { create_list(:assembly, 2, assembly_type: assemblies_type) }

      it { is_expected.to contain_exactly(*assemblies) }
    end
  end
end
