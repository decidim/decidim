# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::HomepageContentBlockCell, type: :cell do
  controller Decidim::Admin::OrganizationHomepageController

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }

  subject { cell("decidim/admin/homepage_content_block", content_block).call }

  it "renders the content block name" do
    expect(subject).to have_content("Hero image")
  end

  it "renders a link to edit the content block" do
    expect(subject).to have_link(href: /edit/)
  end

  it "renders a link to destroy the content block" do
    expect(subject).to have_link(href: /content_blocks/)
  end

  it "renders the drag handle" do
    expect(subject).to have_css("[draggable=\"true\"]")
  end

  context "when content block is not persisted" do
    let(:content_block) { build(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }

    it "does not render edit or destroy links" do
      expect(subject).not_to have_link(href: /edit/)
      expect(subject).not_to have_link(href: /delete/)
    end
  end

  context "when content block has no settings" do
    let(:content_block) do
      create(:content_block, organization:, manifest_name: :sub_hero, scope_name: :homepage)
    end

    it "does not render edit link" do
      expect(subject).not_to have_link(href: /edit/)
    end
  end
end
