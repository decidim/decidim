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
        .with(amendment, form.current_user, kind_of(Hash))
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
    end
  end
end
