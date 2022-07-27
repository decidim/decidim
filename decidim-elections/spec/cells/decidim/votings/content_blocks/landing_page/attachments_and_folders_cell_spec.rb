# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::ContentBlocks::LandingPage::AttachmentsAndFoldersCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  controller Decidim::Votings::VotingsController

  let(:organization) { create(:organization) }
  let(:voting) { create(:voting, :published, organization:) }
  let(:content_block) { create :content_block, organization:, manifest_name: :attachments_and_folders, scope_name: :voting_landing_page }
  let!(:attachment_pdf) { create(:attachment, :with_pdf, attached_to: voting) }
  let!(:attachment_img) { create(:attachment, :with_image, attached_to: voting) }

  before do
    allow(controller).to receive(:current_participatory_space).and_return(voting)
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when rendering attachments" do
    it "shows image attachment" do
      expect(subject).to have_selector(".attachments .thumbnail", count: 1)
    end

    it "shows pdf attachment" do
      expect(subject).to have_selector(".documents .card__link", count: 1)
    end
  end
end
