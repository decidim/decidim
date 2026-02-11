# frozen_string_literal: true

require "spec_helper"
require "./db/data/20260210195653_move_announcement_to_content_block_on_assemblies"

describe MoveAnnouncementToContentBlockOnAssemblies do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:organization) { create(:organization) }

    context "when the assembly has announcement content" do
      let!(:assembly) { create(:assembly, organization:) }

      before do
        # rubocop:disable Rails/SkipsModelValidations
        assembly.update_column(
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
          scope_name: :assembly_homepage,
          manifest_name: :announcement,
          scoped_resource_id: assembly.id
        )

        expect(content_block).to be_present
        expect(content_block).not_to be_published
        expect(content_block.settings["announcement_en"]).to eq("Important announcement")
        expect(content_block.settings["announcement_es"]).to eq("Anuncio importante")
        expect(content_block.settings.to_h).not_to have_key("announcement_machine_translations")
      end

      it "preserves published state while updating settings on an existing active block" do
        content_block = create(
          :content_block,
          organization:,
          scope_name: :assembly_homepage,
          manifest_name: :announcement,
          scoped_resource_id: assembly.id,
          published_at: Time.current,
          settings: { "announcement_en" => "Old" }
        )

        migrator.migrate(:up)

        expect(content_block.reload).to be_published
        expect(content_block.settings["announcement_en"]).to eq("Important announcement")
      end
    end

    context "when the assembly has no announcement content" do
      let!(:assembly) { create(:assembly, organization:) }

      before do
        assembly.update_column(:announcement, {}) # rubocop:disable Rails/SkipsModelValidations
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
