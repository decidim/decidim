# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Engine do
  describe "decidim_proposals.remove_space_admins" do
    let(:component) { create(:proposal_component, participatory_space: space) }
    let(:valuator) { create :user, organization: organization }
    let(:proposal) { create(:proposal, component: component) }

    context "when removing participatory_space admin" do
      let(:space) { valuator_role.participatory_process }
      let(:valuator_role) { create(:participatory_process_user_role) }
      let!(:assignment) { create :valuation_assignment, proposal: proposal, valuator_role: valuator_role }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.system.participatory_space.admin.destroyed", valuator_role.class.name, valuator_role.id)
        end.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
      end
    end

    context "when removing assembly admin" do
      let(:space) { valuator_role.assembly }
      let(:valuator_role) { create(:assembly_user_role) }
      let!(:assignment) { create :valuation_assignment, proposal: proposal, valuator_role: valuator_role }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.system.participatory_space.admin.destroyed", valuator_role.class.name, valuator_role.id)
        end.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
      end
    end

    context "when removing conference admin" do
      let(:space) { valuator_role.conference }
      let(:valuator_role) { create(:conference_user_role) }
      let!(:assignment) { create :valuation_assignment, proposal: proposal, valuator_role: valuator_role }

      it "removes the record" do
        expect do
          ActiveSupport::Notifications.publish("decidim.system.participatory_space.admin.destroyed", valuator_role.class.name, valuator_role.id)
        end.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
      end
    end
  end
end
