# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe ParentAssembliesForSelect do
    subject { described_class.for(organization, assembly) }

    let(:organization) { create(:organization) }
    let!(:assembly) { create(:assembly, organization:) }
    let!(:assemblies) { create_list(:assembly, 3, organization:) }
    let!(:child_assembly) { create(:assembly, :with_parent, parent: assembly, organization:) }
    let!(:grand_child_assembly) { create(:assembly, :with_parent, parent: child_assembly, organization:) }

    describe "query" do
      it "returns assemblies that can be parent" do
        expect(subject.count).to eq(3)
        expect(subject).to match_array(assemblies)
      end

      context "when assembly is nil" do
        let(:assembly) { nil }

        it "returns all assemblies" do
          expected = assemblies
          expected << child_assembly
          expected << grand_child_assembly

          expect(subject.count).to eq(5)
          expect(subject).to match_array(expected)
        end
      end
    end
  end
end
