# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationFieldsJob do
    let(:process) { build :participatory_process, title: title }
    let(:target_locale) { "ca" }
    let(:source_locale) { "en" }
    let(:translated_value) { "#{target_locale} - #{title[source_locale]}" }

    before do
      clear_enqueued_jobs
    end

    describe "for the first machine translation" do
      let(:title) { { source_locale => "New Title" } }

      it "updates the resource" do
        expect(process.title).to eq(title)

        process.save
        MachineTranslationSaveJob.perform_now(
          process,
          "title",
          target_locale,
          translated_value
        )

        expect(process.title).to eq(
          title.merge(
            "machine_translations" => {
              target_locale => translated_value
            }
          )
        )
      end
    end

    describe "when there are other machine translations" do
      let(:title) do
        {
          source_locale => "New Title",
          "machine_translations" => {
            "es" => "es - New Title"
          }
        }
      end

      it "updates the resource" do
        expect(process.title).to eq(title)

        process.save
        MachineTranslationSaveJob.perform_now(
          process,
          "title",
          target_locale,
          translated_value
        )

        expect(process.title).to eq(
          title.merge(
            "machine_translations" => {
              "es" => "es - New Title",
              target_locale => translated_value
            }
          )
        )
      end
    end
  end
end
