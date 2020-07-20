# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationFieldsJob do
    let(:title) { { en: "New Title" } }
    let(:process) { build :participatory_process, title: title }

    describe "When fields job is executed" do
      it "calls DummyTranslator to creates machine translations" do
        process.save
        MachineTranslationFieldsJob.perform_now(
          process,
          "title",
          process["title"]["en"],
          "ca",
          "en"
        )

        allow(Decidim::DummyTranslator)
          .to receive(:new)
          .with(
            process,
            "title",
            process["title"]["en"],
            "en",
            "ca"
          )
        expect(process["title"])
          .to include("machine_translations" => { "ca" => "ca - New Title" })
      end
    end
  end
end
