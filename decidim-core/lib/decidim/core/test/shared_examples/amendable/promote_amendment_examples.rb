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
        .with(:create, emendation.resource_manifest.model_class_name.constantize, emendation.creator_author)
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
    end
  end
end
