# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Elections::AdminLog::ElectionPresenter, type: :helper do
    subject { described_class.new(action_log, helper) }

    let(:action_log) { create(:action_log, action:) }

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      context "when the election is created" do
        let(:action) { :create }

        it "shows the election has been created" do
          expect(subject.present).to include(" created the election ")
          expect(subject.present).not_to include(" on the Bulletin Board")
        end
      end

      context "when the election is updated" do
        let(:action) { :update }

        it "shows the election has been updated" do
          expect(subject.present).to include(" updated the election ")
        end
      end

      context "when the election is deleted" do
        let(:action) { :delete }

        it "shows the election has been deleted" do
          expect(subject.present).to include(" deleted the election ")
        end
      end

      context "when the election is published" do
        let(:action) { :publish }

        it "shows the election has been published" do
          expect(subject.present).to include(" published the ")
        end
      end

      context "when the election is unpublished" do
        let(:action) { :unpublish }

        it "shows the election has been unpublished" do
          expect(subject.present).to include(" unpublished the ")
        end
      end

      context "when the election is setup" do
        let(:action) { :setup }

        it "shows the election has been setup" do
          expect(subject.present).to include(" created the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end

      context "when the key ceremony is started" do
        let(:action) { :start_key_ceremony }

        it "shows the key ceremony has started" do
          expect(subject.present).to include(" started the key ceremony for the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end

      context "when the vote period is started" do
        let(:action) { :start_vote }

        it "shows the voting period has started" do
          expect(subject.present).to include(" started the voting period for the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end

      context "when the vote period is ended" do
        let(:action) { :end_vote }

        it "shows the voting period has ended" do
          expect(subject.present).to include(" ended the voting period for the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end

      context "when the tally is started" do
        let(:action) { :start_tally }

        it "shows the tally has started" do
          expect(subject.present).to include(" started the tally for the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end

      context "when a trustee is reported as missing" do
        let(:action_log) { build(:action_log, action:) }
        let(:action) { :report_missing_trustee }
        let(:trustee) { create(:trustee) }

        before do
          action_log.extra["extra"] = {
            "trustee_id" => trustee.id,
            "name" => "Somebody Trustable",
            "nickname" => "TrustMe"
          }
          action_log.save!
        end

        it "shows the trustee was reported" do
          expect(subject.present).to include("Somebody Trustable")
          expect(subject.present).to include(" as a missing trustee during the tally for the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end

      context "when the election results are published" do
        let(:action) { :publish_results }

        it "shows the election results are published" do
          expect(subject.present).to include(" published the results for the election ")
          expect(subject.present).to include(" on the Bulletin Board")
        end
      end
    end
  end
end
