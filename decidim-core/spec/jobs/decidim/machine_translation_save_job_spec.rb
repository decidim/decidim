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

    describe "when the resource is reported" do
      let(:moderation) { create(:moderation, report_count: 2) }
      let!(:report) { create(:report, moderation: moderation) }
      let(:comment) { build(:comment, body: { "ca" => "Comentari" }, moderation: moderation) }
      let(:target_locale) { "en" }
      let(:translated_value) { "Comment" }

      it "sends emails to the moderators when the target language is the organization's default" do
        allow(ReportedMailer).to receive(:send_report_notification_to_users).and_call_original
        
        comment.save
        MachineTranslationSaveJob.perform_now(
          comment,
          "body",
          target_locale,
          translated_value
        )

        expect(ReportedMailer)
            .to have_received(:send_report_notification_to_users)
            .with(moderation.participatory_space.moderators, report)
      end
    end
  end
end
