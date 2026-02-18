# frozen_string_literal: true

require "spec_helper"
require "./db/data/20260210195709_move_announcement_to_content_block_on_participatory_processes"

describe MoveAnnouncementToContentBlockOnParticipatoryProcesses do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:organization) { create(:organization) }

    context "when the process has announcement content" do
      let!(:participatory_process) { create(:participatory_process, organization:) }

      before do
        # rubocop:disable Rails/SkipsModelValidations
        participatory_process.update_column(
          :announcement,
          {
            "en" => "Important announcement",
            "es" => "Anuncio importante",
            "machine_translations" => { "ca" => "Avís" }
          }
        )
        # rubocop:enable Rails/SkipsModelValidations
      end

      it "creates an inactive announcement content block with settings" do
        expect do
          migrator.migrate(:up)
        end.to change(Decidim::ContentBlock, :count).by(1)

        content_block = Decidim::ContentBlock.find_by(
          organization:,
          scope_name: :participatory_process_homepage,
          manifest_name: :announcement,
          scoped_resource_id: participatory_process.id
        )

        expect(content_block).to be_present
        expect(content_block).not_to be_published
        expect(content_block.settings["announcement_en"]).to eq("Important announcement")
        expect(content_block.settings["announcement_es"]).to eq("Anuncio importante")
        expect(content_block.settings.to_h).not_to have_key("announcement_machine_translations")
      end

      it "preserves published_at while updating settings on an existing active block" do
        content_block = create(
          :content_block,
          organization:,
          scope_name: :participatory_process_homepage,
          manifest_name: :announcement,
          scoped_resource_id: participatory_process.id,
          published_at: Time.current,
          settings: { "announcement_en" => "Old" }
        )

        migrator.migrate(:up)

        expect(content_block.reload).to be_published
        expect(content_block.settings["announcement_en"]).to eq("Important announcement")
      end
    end

    context "when the process has no announcement content" do
      let!(:participatory_process) { create(:participatory_process, organization:) }

      before do
        participatory_process.update_column(:announcement, {}) # rubocop:disable Rails/SkipsModelValidations
      end

      it "does not create a content block" do
        expect { migrator.migrate(:up) }.not_to change(Decidim::ContentBlock, :count)
      end
    end
  end

  describe "#down" do
    it "raises ActiveRecord::IrreversibleMigration" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
