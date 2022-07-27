# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::StatsCell, type: :cell do
  subject { stats_cell.call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization:, manifest_name: :stats, scope_name: :homepage }
  let(:stats_cell) { cell(content_block.cell, content_block) }

  let!(:users) { create_list(:user, 10, :confirmed, organization:) }
  let!(:processes) { create_list(:participatory_process, 5, organization:) }

  let(:other_organization) { create(:organization) }
  let!(:other_users) { create_list(:user, 3, :confirmed, organization: other_organization) }
  let!(:other_processes) { create_list(:participatory_process, 2, organization: other_organization) }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  it "renders the correct stats" do
    expect(subject.find(".statistic__data.users_count .statistic__number")).to have_text("10")
    expect(subject.find(".statistic__data.processes_count .statistic__number")).to have_text("5")
  end

  describe "#cache_hash" do
    subject { stats_cell.send(:cache_hash) }

    let!(:other_cell) { cell(other_content_block.cell, other_content_block) }
    let(:other_content_block) { create :content_block, organization: other_organization, manifest_name: :stats, scope_name: :homepage }

    it "generate a unique hash per organization" do
      target_hash = subject

      allow(controller).to receive(:current_organization).and_return(other_organization)
      expect(target_hash).not_to eq(other_cell.send(:cache_hash))
    end

    context "when switching locale" do
      let(:alt_locale) { :ca }

      before do
        allow(I18n).to receive(:locale).and_return(alt_locale)
      end

      it "generates a different hash" do
        expect(subject).not_to match(/en$/)
      end
    end
  end
end
