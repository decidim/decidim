# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability::Admin
  describe UpdateResultDates do
    subject { described_class.new(start_date, end_date, result_ids, user) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:start_date) { Date.current }
    let(:end_date) { Date.current + 1.month }
    let(:results) { create_list(:result, 3, component: current_component) }
    let(:result_ids) { results.map(&:id) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    context "when everything is ok" do
      it "updates the result dates" do
        subject.call

        results.each do |result|
          expect(result.reload.start_date).to eq(start_date)
          expect(result.reload.end_date).to eq(end_date)
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("update", kind_of(Decidim::Accountability::Result), user)
          .exactly(results.count).times

        subject.call
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      context "when a result already has the same dates" do
        let!(:result_with_dates) do
          create(:result, component: current_component, start_date:, end_date:)
        end
        let(:result_ids) { results.map(&:id) + [result_with_dates.id] }

        it "does not trace the action for that result" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("update", kind_of(Decidim::Accountability::Result), user)
            .exactly(results.count).times

          subject.call
        end
      end

      context "when updating only start_date" do
        let(:end_date) { nil }

        it "updates only the start date" do
          subject.call

          results.each do |result|
            expect(result.reload.start_date).to eq(start_date)
            expect(result.reload.end_date).to be_nil
          end
        end
      end

      context "when updating only end_date" do
        let(:start_date) { nil }

        it "updates only the end date" do
          subject.call

          results.each do |result|
            expect(result.reload.start_date).to be_nil
            expect(result.reload.end_date).to eq(end_date)
          end
        end
      end
    end

    context "when both dates are nil" do
      let(:start_date) { nil }
      let(:end_date) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when result_ids is empty" do
      let(:result_ids) { [] }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
