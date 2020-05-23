# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe PublishComponent do
    subject { described_class.new(component, user) }

    let!(:user) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:step) { participatory_process.steps.first }
    let!(:component) { create(:component, :unpublished, participatory_space: participatory_process) }

    it "publishes the component" do
      expect { subject.call }.to change(component, :published?).from(false).to(true)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:publish, component, user, visibility: "all")
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    it "fires an event" do
      create :follow, followable: participatory_process, user: user

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.components.component_published",
          event_class: Decidim::ComponentPublishedEvent,
          resource: component,
          followers: [user]
        )

      subject.call
    end

    context "when the component has a parent" do
      let(:parent_component) { create(:component, participatory_space: participatory_process) }
      let!(:component) { create(:component, :unpublished, parent: parent_component) }

      it "publishes the component" do
        expect { subject.call }.to change(component, :published?).from(false).to(true)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:publish, component, user, visibility: "all")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "doesn't fire an event" do
        create :follow, followable: participatory_process, user: user

        expect(Decidim::EventsManager)
          .not_to receive(:publish)

        subject.call
      end
    end
  end
end
