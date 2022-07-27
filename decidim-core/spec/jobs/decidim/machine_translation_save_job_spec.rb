# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationFieldsJob do
    let(:process) { build :participatory_process, title: }
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
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let!(:moderators) { create_list(:user, 3, :admin, organization:) }
      let(:moderation) { create(:moderation, report_count: 2, participatory_space:) }
      let!(:report) { create(:report, moderation:) }
      let(:title) { { "ca" => "Títol" } }
      let(:proposal) { build(:proposal, title:, body: { "ca" => "Proposta" }, moderation:) }
      let(:translated_value) { "Proposal" }

      describe "and the target language is the organization's default" do
        let(:target_locale) { "en" }

        describe "and the resource is completely translated" do
          let(:title) { { "ca" => "Títol", "machine_translations" => { "en" => "Title" } } }

          it "sends emails to the moderators" do
            allow(ReportedMailer).to receive(:report).and_call_original

            proposal.save
            MachineTranslationSaveJob.perform_now(
              proposal,
              "body",
              target_locale,
              translated_value
            )

            expect(ReportedMailer)
              .to have_received(:report)
              .exactly(moderation.participatory_space.moderators.count).times
          end
        end

        describe "and the resource is NOT completely translated" do
          it "doesn't send emails" do
            allow(ReportedMailer).to receive(:report).and_call_original

            proposal.save
            MachineTranslationSaveJob.perform_now(
              proposal,
              "body",
              target_locale,
              translated_value
            )

            expect(ReportedMailer)
              .not_to have_received(:report)
          end
        end
      end

      describe "and the target language is NOT the organization's default" do
        let(:target_locale) { "fi" }

        it "doesn't send emails" do
          allow(ReportedMailer).to receive(:report).and_call_original

          proposal.save
          MachineTranslationSaveJob.perform_now(
            proposal,
            "body",
            target_locale,
            translated_value
          )

          expect(ReportedMailer)
            .not_to have_received(:report)
        end
      end
    end
  end
end
