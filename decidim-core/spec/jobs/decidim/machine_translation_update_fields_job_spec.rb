# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationUpdateFieldsJob do
    let(:dummy_resource) { build :dummy_resource }
    it "creates record in translation field" do
      dummy_resource.save
      create :translated_field, translated_resource: dummy_resource, translation_locale: "ca"
      expect do
        MachineTranslationUpdateFieldsJob.perform_now(
          dummy_resource.id,
          Decidim::DummyResources::DummyResource.name,
          "title",
          dummy_resource["title"],
          "ca",
          "en"
        )
      end.not_to change{ Decidim::TranslatedField.count }
    end
  end
end