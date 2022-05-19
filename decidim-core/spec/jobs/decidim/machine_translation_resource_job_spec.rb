# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationResourceJob do
    let(:title) { { en: "New Title", es: "nuevo título", machine_translations: { ca: "nou títol" } } }
    let(:organization) { create :organization, default_locale: "en" }
    let(:process) { create :participatory_process, title: title, organization: organization }
    let(:current_locale) { "en" }

    before do
      allow(Decidim).to receive(:machine_translation_service_klass).and_return(Decidim::Dev::DummyTranslator)
    end

    context "when the default locale of translatable field changes" do
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
          .on_queue("translations")
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

    describe "when the content is submitted in other language than default" do
      let(:current_locale) { "es" }

      before do
        updated_title = { es: "título actualizado" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "doesn't enqueue the machine translation fields job" do
        Decidim::MachineTranslationResourceJob.perform_now(
          process,
          process.translatable_previous_changes,
          current_locale
        )
        expect(Decidim::MachineTranslationFieldsJob)
          .to have_been_enqueued
          .on_queue("translations")
          .exactly(2).times
          .with(
            process,
            "title",
            "título actualizado",
            kind_of(String),
            current_locale
          )
      end
    end

    describe "when default locale of translatable field isn't changed" do
      before do
        updated_title = { en: "New Title", es: "título actualizado" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "doesn't enqueue the machine translation fields job" do
        Decidim::MachineTranslationResourceJob.perform_now(
          process,
          process.translatable_previous_changes,
          current_locale
        )
        expect(Decidim::MachineTranslationFieldsJob)
          .not_to have_been_enqueued
          .on_queue("translations")
      end
    end

    describe "if default locale isn't changed but locale changed is set to empty" do
      before do
        updated_title = { en: "New Title", es: "" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "enqueus the machine translation fields job" do
        Decidim::MachineTranslationResourceJob.perform_now(
          process,
          process.translatable_previous_changes,
          current_locale
        )
        expect(Decidim::MachineTranslationFieldsJob)
          .to have_been_enqueued
          .on_queue("translations")
          .exactly(1).times
          .with(
            process,
            "title",
            "New Title",
            "es",
            current_locale
          )
      end
    end

    context "when machine translations are duplicated" do
      let(:new_title) { { en: "New Title", machine_translations: { es: "nuevo título" } } }
      let!(:process) { create :participatory_process, title: new_title }

      before do
        updated_title = { en: "New Title", es: "nuevo título" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "removes the duplicated machine translation" do
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
