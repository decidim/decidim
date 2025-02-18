# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability::Admin
  describe UpdateResultStatus do
    subject { described_class.new(status_id, result_ids, user) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:status) { create(:status, component: current_component) }
    let(:status_id) { status.id }
    let(:results) { create_list(:result, 3, component: current_component) }
    let(:result_ids) { results.map(&:id) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    context "when everything is ok" do
      it "updates the result status" do
        subject.call

        results.each do |result|
          expect(result.reload.status).to eq(status)
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

      context "when a result already has the status" do
        let!(:result_with_status) { create(:result, component: current_component, status:) }
        let(:result_ids) { results.map(&:id) + [result_with_status.id] }

        it "does not trace the action for that result" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("update", kind_of(Decidim::Accountability::Result), user)
            .exactly(results.count).times

          subject.call
        end
      end
    end

    context "when status_id is nil" do
      let(:status_id) { nil }

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
