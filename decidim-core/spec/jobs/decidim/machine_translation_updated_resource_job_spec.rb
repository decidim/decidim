# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationUpdatedResourceJob do
    let(:dummy_resource) { create :dummy_resource }
    let(:process) { create :participatory_process }
    let(:current_locale) { "en" }

    context "when the translatable field changes" do
      it "enqueues the updated fields job" do
        dummy_resource.title = "New title"
        dummy_resource.save
        Decidim::MachineTranslationUpdatedResourceJob.perform_now(
          dummy_resource,
          dummy_resource.translatable_previous_changes,
          current_locale
        )
        expect(Decidim::MachineTranslationUpdateFieldsJob)
        .to have_been_enqueued
        .on_queue("default")
        .exactly(2)
        .times
        .with(
          dummy_resource.id,
          dummy_resource.class.name,
          "title",
          dummy_resource.title,
          any_args
        )
      end
    end

    it "only enqueues the job on changing current locale" do
      old_title = process.title
      process.title = Decidim::Faker::Localized.name
      process.title[current_locale]=old_title[current_locale]
      process.save
      Decidim::MachineTranslationUpdatedResourceJob.perform_now(
        process,
        process.translatable_previous_changes,
        current_locale
      )
      expect(Decidim::MachineTranslationUpdateFieldsJob).not_to have_been_enqueued.on_queue("default")
    end
  end
end
