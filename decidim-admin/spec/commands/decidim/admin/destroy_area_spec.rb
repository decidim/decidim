# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyArea do
    subject { described_class.new(area, user) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: organization }
    let(:area) { create :area, organization: organization }

    it "destroys the area" do
      subject.call
      expect { area.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "delete",
          area,
          user
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    context "when a participatory process associated to a given area exist" do
      let!(:process) { create(:participatory_process, organization: area.organization, area: area) }

      it "can not be deleted" do
        expect { subject.call }.to broadcast(:has_spaces)
        area.reload
        expect(area.destroyed?).to be false
      end
    end

    context "when an assembly associated to a given area exist" do
      let!(:process) { create(:assembly, organization: area.organization, area: area) }

      it "can not be deleted" do
        expect { subject.call }.to broadcast(:has_spaces)
        area.reload
        expect(area.destroyed?).to be false
      end
    end
  end
end
