# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ModerationStats do
    let(:admin) { create(:user, :admin, :confirmed) }
    let(:query) { described_class.new(admin) }
    let(:organization) { admin.organization }

    describe "#count_content_moderations" do
      context "when there is no data" do
        it "returns 0 matches" do
          expect(query.count_content_moderations).to eq(0)
        end
      end

      context "when executing query" do
        let(:current_component) { create(:dummy_component, organization:) }
        let(:reportables) { create_list(:dummy_resource, 4, component: current_component) }
        let(:moderations) do
          reportables.first(3).map do |reportable|
            moderation = create(:moderation, reportable:, report_count: 1, reported_content: reportable.reported_searchable_content_text)
            create(:report, moderation:)
            moderation
          end
        end
        let!(:moderation) { moderations.first }
        let!(:hidden_moderations) do
          moderation = create(:moderation, reportable: reportables.last, report_count: 3, reported_content: reportables.last.reported_searchable_content_text, hidden_at: Time.current)
          create_list(:report, 3, moderation:, reason: :spam)
          [moderation]
        end

        it "displays the right number" do
          expect(query.count_content_moderations).to eq(3)
        end
      end
    end

    describe "#count_user_pending_reports" do
      context "when there is no data" do
        it "returns 0 matches" do
          expect(query.count_user_pending_reports).to eq(0)
        end
      end

      context "when executing query" do
        let(:reported_user) { create(:user, :confirmed, organization:) }
        let!(:moderation) { create(:user_moderation, user: reported_user, report_count: 1) }
        let!(:report) { create(:user_report, moderation:, user: admin, reason: "spam") }

        it "returns some matches" do
          expect(query.count_user_pending_reports).to eq(1)
        end
      end
    end

    describe "#count_pending_moderations" do
      context "when there is no data" do
        it "returns 0 matches" do
          expect(query.count_pending_moderations).to eq(0)
        end
      end

      context "when executing query" do
        context "when there are users reported" do
          before do
            allow(query).to receive(:count_user_pending_reports).and_return(2)
            allow(query).to receive(:count_content_moderations).and_return(0)
          end

          it "returns some matches" do
            expect(query.count_pending_moderations).to eq(2)
          end
        end

        context "when there is some content reported" do
          before do
            allow(query).to receive(:count_user_pending_reports).and_return(0)
            allow(query).to receive(:count_content_moderations).and_return(2)
          end

          it "displays the right number" do
            expect(query.count_pending_moderations).to eq(2)
          end
        end

        context "when we have users and content reported" do
          before do
            allow(query).to receive(:count_user_pending_reports).and_return(2)
            allow(query).to receive(:count_content_moderations).and_return(2)
          end

          it "displays the right number" do
            expect(query.count_pending_moderations).to eq(4)
          end
        end
      end
    end
  end
end
