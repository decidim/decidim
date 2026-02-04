# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :highlighted_processes, scope_name: :homepage, settings:) }
  let!(:processes) { create_list(:participatory_process, 8, organization:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 6 processes" do
      expect(subject).to have_css("a.card__grid", count: 6)
    end
  end

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "max_results" => "9"
      }
    end

    it "shows up to 8 processes" do
      expect(subject).to have_css("a.card__grid", count: 8)
    end
  end

  describe "#cache_hash" do
    let(:processes) { create_list(:participatory_process, 2, :active, :with_steps, organization:) }

    it "generates a unique hash" do
      content_block.reload
      old_hash = cell(content_block.cell, content_block).send(:cache_hash)
      content_block.reload

      expect(cell(content_block.cell, content_block).send(:cache_hash)).to eq(old_hash)
    end

    context "when participatory process active_step is updated" do
      it "generates a different hash" do
        old_hash = cell(content_block.cell, content_block).send(:cache_hash)
        active_step = processes.first.active_step
        active_step.update!(title: { en: "Updated title" })

        expect(cell(content_block.cell, content_block).send(:cache_hash)).not_to eq(old_hash)
      end
    end

    context "when parent process is touched via step update" do
      it "generates a different hash when process is touched" do
        old_hash = cell(content_block.cell, content_block).send(:cache_hash)
        process = processes.first

        travel_to(1.second.from_now) do
          process.update(updated_at: Time.current)
        end

        expect(cell(content_block.cell, content_block).send(:cache_hash)).not_to eq(old_hash)
      end
    end

    context "when current locale change" do
      let(:alt_locale) { :ca }

      before do
        allow(I18n).to receive(:locale).and_return(alt_locale)
      end

      it "generates a different hash" do
        expect(cell(content_block.cell, content_block).send(:cache_hash)).not_to match(/en$/)
      end
    end
  end
end
