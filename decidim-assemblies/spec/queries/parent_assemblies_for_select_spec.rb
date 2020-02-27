# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe ParentAssembliesForSelect do
    subject { described_class.for(organization, assembly) }

    let(:organization) { create(:organization) }
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:assemblies) { create_list(:assembly, 3, organization: organization) }
    let!(:child_assembly) { create(:assembly, :with_parent, parent: assembly, organization: organization) }
    let!(:grand_child_assembly) { create(:assembly, :with_parent, parent: child_assembly, organization: organization) }

    describe "query" do
      it "returns assemblies that can be parent" do
        expect(subject.count).to eq(3)
        expect(subject).to eq(assemblies)
      end
    end
  end
end
