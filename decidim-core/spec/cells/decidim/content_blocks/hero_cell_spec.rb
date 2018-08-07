# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HeroCell, type: :cell do
  subject { cell(content_block.cell_name, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :hero, scope: :homepage, settings: settings }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows the default welcome text" do
      expect(subject).to have_text("Welcome to #{organization.name}")
    end
  end

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "welcome_text_en" => "This is my welcome text"
      }
    end

    it "shows the custom welcome text" do
      expect(subject).to have_text("This is my welcome text")
    end
  end
end
