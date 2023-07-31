# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe TrainHiddenResourceDataJob do
      subject { described_class }

      shared_examples "a train hidden resource data job" do
        let(:backend) { ClassifierReborn::BayesMemoryBackend.new }

        let(:bayes_classifier) { ClassifierReborn::Bayes.new :spam, :ham, backend: }
        let(:algorithm) { Decidim::Ai::SpamDetection::Strategy::Bayes.new({}) }

        before do
          Decidim::Ai.spam_detection_registry.clear
          allow(algorithm).to receive(:backend).and_return(bayes_classifier)
          allow(Decidim::Ai.spam_detection_registry).to receive(:strategies).and_return([algorithm])
          Decidim::Ai.spam_detection_instance.train(:ham, text)
        end

        it "adds data to spam" do
          expect(backend.category_word_count(:ham)).to eq(4)
          expect(backend.category_word_count(:spam)).to eq(0)

          moderation = Decidim::Moderation.find_or_create_by!(reportable:, participatory_space: participatory_process)
          moderation.update!(
            reported_content: text,
            report_count: Decidim.max_reports_before_hiding,
            hidden_at: Time.current
          )
          Decidim::Report.create!(
            moderation:,
            user: author,
            reason: "spam",
            details: "testing purposes",
            locale: I18n.locale
          )

          subject.perform_now(reportable)
          expect(backend.category_word_count(:ham)).to eq(0)
          expect(backend.category_word_count(:spam)).to eq(4)
        end
      end

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:author) { create(:user, organization:) }
      let(:text) { "This is a very good idea!" }

      context "when the reportable is a comment" do
        it_behaves_like "a train hidden resource data job" do
          let(:component) { create(:component, participatory_space: participatory_process) }
          let(:dummy_resource) { create(:dummy_resource, component:) }
          let(:commentable) { dummy_resource }
          let!(:comment) { create(:comment, author:, commentable:, body: { en: text }) }

          let(:reportable) { comment }
        end
      end

      context "when the reportable is a proposal" do
        it_behaves_like "a train hidden resource data job" do
          let(:component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }
          let(:reportable) { create(:proposal, component:, users: [author], title: { en: text }, body: { en: "" }) }
        end
      end

      context "when the reportable is a collaborative draft" do
        it_behaves_like "a train hidden resource data job" do
          let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled, participatory_space: participatory_process) }
          let(:reportable) { create(:collaborative_draft, component:, users: [author], title: text, body: "") }
        end
      end

      context "when the reportable is a meeting" do
        it_behaves_like "a train hidden resource data job" do
          let(:component) { create(:meeting_component, participatory_space: participatory_process) }
          let(:reportable) do
            create(:meeting, component:, author:, title: { en: text }, description: { en: "" },
                             location_hints: { en: "" }, registration_terms: { en: "" }, closing_report: { en: "" })
          end
        end
      end

      context "when the reportable is a debate" do
        it_behaves_like "a train hidden resource data job" do
          let(:component) { create(:component, manifest_name: "debates", participatory_space: participatory_process) }
          let(:reportable) { create(:debate, component:, author:, title: { en: text }, description: { en: "" }) }
        end
      end
    end
  end
end
