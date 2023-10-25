# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::ContentBlocks::MainDataCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) do
    create(
      :content_block,
      manifest_name: :main_data,
      scope_name: :assembly_homepage,
      scoped_resource_id: assembly.id
    )
  end
  let!(:assembly) do
    create(
      :assembly,
      short_description: { en: short_description },
      purpose_of_action: { en: purpose_of_action },
      internal_organisation: { en: internal_organisation },
      composition: { en: composition }
    )
  end
  let(:short_description) { "This is my short description" }
  let(:purpose_of_action) { "" }
  let(:internal_organisation) { "" }
  let(:composition) { "" }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  it "shows the title" do
    expect(subject).to have_content("About this assembly")
  end

  it "shows the short description" do
    expect(subject).to have_content(short_description)
  end

  shared_examples_for "with extra attribute" do
    it "shows it" do
      expect(subject).to have_content(attribute_title)
      expect(subject).to have_content(attribute_content)
    end
  end

  shared_examples_for "without extra attribute" do
    it "does not show it" do
      expect(subject).not_to have_content(attribute_title)
      expect(subject).not_to have_content(attribute_content)
    end
  end

  describe "purpose_of_action" do
    let(:attribute_title) { "Purpose of action" }
    let(:attribute_content) { purpose_of_action }

    context "when there is the extra attribute" do
      let(:purpose_of_action) { "This is my purpose" }

      it_behaves_like "with extra attribute"
    end

    context "when there is no extra attribute" do
      let(:purpose_of_action) { "<p></p>" }

      it_behaves_like "without extra attribute"
    end
  end

  describe "internal_organisation" do
    let(:attribute_title) { "Internal organisation" }
    let(:attribute_content) { internal_organisation }

    context "when there is the extra attribute" do
      let(:internal_organisation) { "This is my internal organisation" }

      it_behaves_like "with extra attribute"
    end

    context "when there is no extra attribute" do
      let(:internal_organisation) { "<p></p>" }

      it_behaves_like "without extra attribute"
    end
  end

  describe "composition" do
    let(:attribute_title) { "Composition" }
    let(:attribute_content) { composition }

    context "when there is the extra attribute" do
      let(:composition) { "This is my composition" }

      it_behaves_like "with extra attribute"
    end

    context "when there is no extra attribute" do
      let(:composition) { "<p></p>" }

      it_behaves_like "without extra attribute"
    end
  end
end
