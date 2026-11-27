# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261113120000_rename_component_step_settings"

describe RenameComponentStepSettings do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let!(:component) do
    created = create(:component)
    new_settings = {
      "global" => { "comments_max_length" => 10 },
      "default_step" => { "dummy_phase_attribute1" => true },
      "steps" => { "1" => { "dummy_phase_attribute1" => false } }
    }
    created.update_column(:settings, new_settings) # rubocop:disable Rails/SkipsModelValidations
    created
  end

  describe "#up" do
    it "renames the component settings keys" do
      migrator.migrate(:up)

      settings = component.reload[:settings]
      expect(settings).not_to include("steps", "default_step")
      expect(settings["phases"]).to eq("1" => { "dummy_phase_attribute1" => false })
      expect(settings["default_phase"]).to eq("dummy_phase_attribute1" => true)
      expect(settings["global"]).to eq("comments_max_length" => 10)
    end
  end

  describe "#down" do
    it "renames the component settings keys back" do
      migrator.migrate(:up)
      migrator.migrate(:down)

      settings = component.reload[:settings]
      expect(settings).not_to include("phases", "default_phase")
      expect(settings["steps"]).to eq("1" => { "dummy_phase_attribute1" => false })
      expect(settings["default_step"]).to eq("dummy_phase_attribute1" => true)
      expect(settings["global"]).to eq("comments_max_length" => 10)
    end
  end
end
