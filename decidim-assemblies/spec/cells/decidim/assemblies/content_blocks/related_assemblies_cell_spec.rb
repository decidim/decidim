# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::ContentBlocks::RelatedAssembliesCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  controller Decidim::Assemblies::AssembliesController

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name:, scope_name:, settings:, scoped_resource_id: parent_assembly.id) }
  let(:manifest_name) { :related_assemblies }
  let(:scope_name) { :assembly_homepage }
  let(:settings) { {} }
  let(:parent_assembly) { create(:assembly, organization:) }
  let!(:child_assemblies) { create_list(:assembly, 8, organization:, parent: parent_assembly, created_at: 1.day.ago) }

  context "when the content block has no settings" do
    it "shows 6 assemblies" do
      expect(subject).to have_css("a.card__grid", count: 6)
    end
  end

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "max_results" => "9"
      }
    end

    it "shows up to 8 assemblies" do
      expect(subject).to have_css("a.card__grid", count: 8)
    end
  end
end
