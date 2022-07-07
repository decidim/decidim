# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyComponent do
    subject { described_class.new(component, current_user) }

    let!(:component) { create(:component) }
    let!(:current_user) { create(:user, organization: component.participatory_space.organization) }

    context "when everything is ok" do
      it "destroys the component" do
        subject.call
        expect(Decidim::Component.where(id: component.id)).not_to exist
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", component, current_user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end

      it "fires the hooks" do
        results = {}

        component.manifest.on(:destroy) do |component|
          results[:component] = component
        end

        subject.call

        result_component = results[:component]
        expect(result_component.id).to eq(component.id)
        expect(result_component).not_to be_persisted
      end
    end
  end
end
