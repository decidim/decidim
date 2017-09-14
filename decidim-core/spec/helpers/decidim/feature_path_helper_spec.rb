# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FeaturePathHelper do
    let(:participatory_process) { create(:participatory_process, slug: "my-process") }

    let(:feature) do
      create(:feature, id: 21, participatory_space: participatory_process)
    end

    describe "main_feature_path" do
      it "resolves the root path for the feature" do
        expect(helper.main_feature_path(feature)).to eq("/processes/my-process/f/21/")
      end
    end

    describe "manage_feature_path" do
      it "resolves the admin root path for the feature" do
        expect(helper.manage_feature_path(feature)).to \
          eq("/admin/participatory_processes/my-process/features/21/manage/")
      end
    end
  end
end
