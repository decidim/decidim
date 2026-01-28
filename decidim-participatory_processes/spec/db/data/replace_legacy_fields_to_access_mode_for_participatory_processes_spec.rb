# frozen_string_literal: true

require "spec_helper"
require "./db/data/20260111190000_replace_legacy_fields_to_access_mode_for_participatory_processes"

describe ReplaceLegacyFieldsToAccessModeForParticipatoryProcesses do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    shared_examples_for "converts private_space to access mode" do |describe_title, example_title, private_space, expected_mode|
      describe describe_title do
        let!(:process) { create(:participatory_process, private_space:) }

        it example_title do
          # Ensure starting state
          expect(process.reload.private_space).to eq(private_space)

          migrator.migrate(:up)

          expect(process.reload.access_mode).to eq(expected_mode)
          # Legacy field should remain unchanged
          expect(process.reload.private_space).to eq(private_space)
        end
      end
    end

    it_behaves_like "converts private_space to access mode",
                    "with private space",
                    "sets access_mode to restricted",
                    true,
                    "restricted"

    it_behaves_like "converts private_space to access mode",
                    "with public space",
                    "sets access_mode to open",
                    false,
                    "open"

    describe "with multiple participatory processes" do
      let!(:restricted_process) { create(:participatory_process, private_space: true) }
      let!(:open_process) { create(:participatory_process, private_space: false) }

      it "converts all processes correctly" do
        migrator.migrate(:up)

        expect(restricted_process.reload.access_mode).to eq("restricted")
        expect(open_process.reload.access_mode).to eq("open")
      end
    end

    describe "with no participatory processes" do
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
