# frozen_string_literal: true

require "spec_helper"
require "./db/data/20260111185230_replace_legacy_fields_to_access_mode_for_assemblies"

describe ReplaceLegacyFieldsToAccessModeForAssemblies do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    shared_examples_for "converts legacy fields to access mode" do |describe_title, example_title, private_space, is_transparent, expected_mode|
      describe describe_title do
        let!(:assembly) { create(:assembly, private_space:, is_transparent:) }

        it example_title do
          # Ensure starting state
          expect(assembly.reload.private_space).to eq(private_space)
          expect(assembly.reload.is_transparent).to eq(is_transparent)

          migrator.migrate(:up)

          expect(assembly.reload.access_mode).to eq(expected_mode)
          # Legacy fields should remain unchanged
          expect(assembly.reload.private_space).to eq(private_space)
          expect(assembly.reload.is_transparent).to eq(is_transparent)
        end
      end
    end

    it_behaves_like "converts legacy fields to access mode",
                    "with private space and not transparent",
                    "sets access_mode to restricted",
                    true,
                    false,
                    "restricted"

    it_behaves_like "converts legacy fields to access mode",
                    "with public space and transparent",
                    "sets access_mode to transparent",
                    false,
                    true,
                    "open"

    it_behaves_like "converts legacy fields to access mode",
                    "with public space and not transparent",
                    "sets access_mode to open",
                    false,
                    false,
                    "open"

    it_behaves_like "converts legacy fields to access mode",
                    "with private space and transparent",
                    "sets access_mode to transparent",
                    true,
                    true,
                    "transparent"

    describe "with multiple assemblies" do
      let!(:open_assembly) { create(:assembly, private_space: false, is_transparent: false) }
      let!(:restricted_assembly) { create(:assembly, private_space: true, is_transparent: false) }
      let!(:transparent_assembly) { create(:assembly, private_space: true, is_transparent: true) }

      it "converts all assemblies correctly" do
        migrator.migrate(:up)

        expect(open_assembly.reload.access_mode).to eq("open")
        expect(restricted_assembly.reload.access_mode).to eq("restricted")
        expect(transparent_assembly.reload.access_mode).to eq("transparent")
      end
    end

    describe "with no assemblies" do
      it "runs without error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end
  end

  describe "#down" do
    it "raises IrreversibleMigration exception" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
