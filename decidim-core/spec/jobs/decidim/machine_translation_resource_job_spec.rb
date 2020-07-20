# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationResourceJob do
    let(:title) { { en: "New Title" } }
    let(:process) { create :participatory_process, title: title }
    let(:current_locale) { "en" }

    context "when the translatable field changes" do
      before do
        updated_title = { en: "Updated Title" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "enqueues the machine translation fields job" do
        Decidim::MachineTranslationResourceJob.perform_now(
          process,
          process.translatable_previous_changes,
          current_locale
        )

        expect(Decidim::MachineTranslationFieldsJob)
          .to have_been_enqueued
          .on_queue("default")
          .exactly(2).times
          .with(
            process,
            "title",
            "Updated Title",
            kind_of(String),
            current_locale
          )
      end
    end

    context "when machine translations are dublicated" do
      let(:new_title) { { en: "New Title", machine_translations: { ca: "nuevo título" } } }
      let!(:process) { create :participatory_process, title: new_title }

      before do
        updated_title = { en: "New Title", ca: "Updated Title" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "enqueues the machine translation fields job" do
        Decidim::MachineTranslationResourceJob.perform_now(
          process,
          process.translatable_previous_changes,
          current_locale
        )

        expect(process[:title]).not_to include(:machine_translations)
      end
    end
  end
end
