# frozen_string_literal: true

shared_examples "reject amendment" do
  describe "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "changes the emendation state to rejected" do
      expect { command.call }.to change(emendation, :state)
        .from("evaluating").to("rejected")
    end

    it "traces the action", versioning: true do
      amendment.state = "rejected"

      expect(Decidim.traceability)
        .to receive(:update!)
        .with(
          amendment,
          amendable.creator_author,
          state: "rejected"
        ).and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "notifies the change" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.amendments.amendment_rejected",
          event_class: Decidim::Amendable::AmendmentRejectedEvent,
          resource: emendation,
          recipient_ids: kind_of(Array)
        )

      command.call
    end
  end
end
