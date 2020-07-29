# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationFieldsJob do
    let(:title) { { en: "New Title" } }
    let(:process) { build :participatory_process, title: title }
    let(:target_locale) { "ca" }
    let(:source_locale) { "en" }

    describe "When fields job is executed" do
      before do
        clear_enqueued_jobs
      end

      it "calls DummyTranslator to creates machine translations" do
        process.save
        MachineTranslationFieldsJob.perform_now(
          process,
          "title",
          process["title"][source_locale],
          target_locale,
          source_locale
        )

        allow(Decidim::DummyTranslator)
          .to receive(:new)
          .with(
            process,
            "title",
            process["title"][source_locale],
            target_locale,
            source_locale
          )
        expect(process["title"])
          .to include("machine_translations" => { target_locale => "ca - New Title" })
      end
    end
  end
end
