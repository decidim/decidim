# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe DiffRenderer do
      subject { described_class.new(version).diff }

      let(:proposal) { create(:proposal) }
      let(:version) { PaperTrail::Version.create(item: proposal, event: "update", object_changes: { title: [title, other_title] }) }

      context "with title as string" do
        let(:title) { generate(:title) }
        let(:other_title) { generate(:title) }

        it "renders an empty diff" do
          expect(subject).to be_empty
        end
      end

      context "with title as translatable string" do
        let(:title) { generate_localized_title(:proposal_title, skip_injection: true) }
        let(:other_title) { generate_localized_title(:proposal_title, skip_injection: true) }

        it "renders the diff successfully" do
          expect(subject.dig(:title_en, :old_value)).to eq(title[:en])
          expect(subject.dig(:title_en, :new_value)).to eq(other_title[:en])
        end
      end

      context "with proposal response fields" do
        let(:answer) { { "en" => "<p>Initial answer</p>" } }
        let(:other_answer) { { "en" => "<p>Updated answer</p>" } }
        let(:cost_report) { { "en" => "<p>Initial cost report</p>" } }
        let(:other_cost_report) { { "en" => "<p>Updated cost report</p>" } }
        let(:execution_period) { { "en" => "<p>Initial execution period</p>" } }
        let(:other_execution_period) { { "en" => "<p>Updated execution period</p>" } }
        let(:version) do
          PaperTrail::Version.create(
            item: proposal,
            event: "update",
            object_changes: {
              answer: [answer, other_answer],
              cost: [100, 200],
              cost_report: [cost_report, other_cost_report],
              execution_period: [execution_period, other_execution_period]
            }
          )
        end

        it "renders changes to proposal response fields" do
          expect(subject).to include(
            answer_en: hash_including(
              type: :i18n_html,
              old_value: answer["en"],
              new_value: other_answer["en"]
            ),
            cost: hash_including(type: :string, old_value: 100, new_value: 200),
            cost_report_en: hash_including(
              type: :i18n_html,
              old_value: cost_report["en"],
              new_value: other_cost_report["en"]
            ),
            execution_period_en: hash_including(
              type: :i18n_html,
              old_value: execution_period["en"],
              new_value: other_execution_period["en"]
            )
          )
        end
      end
    end
  end
end
