# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe ParentAssemblies do
    subject { described_class.new }

    let!(:parent_assembly) { create(:assembly) }
    let!(:child_assembly) { create(:assembly, :with_parent) }

    describe "query" do
      it "only returns parent assemblies" do
        expect(subject.count).to eq(2)
        expect(subject.pluck(:id)).to match_array([parent_assembly.id, child_assembly.parent.id])
      end
    end
  end
end
