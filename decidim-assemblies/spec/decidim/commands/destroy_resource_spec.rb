# frozen_string_literal: true

require "spec_helper"

describe Decidim::Commands::DestroyResource do
  context "when the resource is an assembly type" do
    subject { described_class.new(assembly_type, user) }

    let(:organization) { create(:organization) }
    let(:assembly_type) { create(:assemblies_type, organization:) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    context "when everything is ok" do
      it "destroys the assembly type" do
        subject.call
        expect { assembly_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(
            :delete,
            assembly_type,
            user
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end

    context "when the resource is an assembly" do
      subject { described_class.new(area, user) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:area) { create(:area, organization:) }

      context "when an assembly associated to a given area exist" do
        let!(:assembly) { create(:assembly, organization:, area:) }

        it "cannot be deleted" do
          expect { subject.call }.to broadcast(:has_spaces)
          expect(area.reload.destroyed?).to be false
        end
      end
    end
  end
end
