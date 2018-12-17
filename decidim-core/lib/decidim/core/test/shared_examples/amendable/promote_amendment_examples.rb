# frozen_string_literal: true

shared_examples "promote amendment" do
  describe "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "creates an amendable type resource" do
      expect { command.call }
        .to change(amendable.resource_manifest.model_class_name.constantize, :count)
        .by(1)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "promote",
          emendation.resource_manifest.model_class_name.constantize,
          emendation.creator_author,
          visibility: "public-only",
          promoted_from: emendation.id
        ).and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "notifies the change" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.amendments.amendment_promoted",
          event_class: Decidim::Amendable::EmendationPromotedEvent,
          resource: emendation,
          affected_users: kind_of(Array),
          followers: kind_of(Array)
        )

      command.call
    end
  end
end
