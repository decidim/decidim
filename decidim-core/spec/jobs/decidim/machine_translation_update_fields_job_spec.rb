# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationUpdateFieldsJob do
    let(:dummy_resource) { build :dummy_resource }
    let!(:translated_field) { create :translated_field, translated_resource: dummy_resource, translation_locale: "ca" }

    it "creates record in translation field" do
      dummy_resource.save
       
      expect do
        MachineTranslationUpdateFieldsJob.perform_now(
          dummy_resource,
          "title",
          dummy_resource["title"],
          "ca",
          "en"
        )
      end.to change(translated_field, :translation_value)
    end
  end
end
