# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationCreateFieldsJob do
    let(:dummy_resource) { build :dummy_resource }

    it "creates record in translation field" do
      dummy_resource.save
      expect do
        MachineTranslationCreateFieldsJob.perform_now(
          dummy_resource,
          "title",
          dummy_resource["title"],
          "ca",
          "en"
        )
      end.to change { Decidim::TranslatedField.count }.by(1)
    end
  end
end
