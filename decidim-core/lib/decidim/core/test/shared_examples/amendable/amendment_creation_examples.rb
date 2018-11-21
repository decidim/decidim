# frozen_string_literal: true

shared_examples "amendment creation" do
  context "when the form is invalid" do
    let(:form_params) do
      {
        amendable_gid: nil,
        emendation_fields: nil
      }
    end

    it "does not create a amendment" do
      expect { command.call }.not_to change(Decidim::Amendment, :count)
    end

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end

    it "does not send notifications" do
      expect do
        perform_enqueued_jobs { command.call }
      end.not_to change(emails, :count)
    end
  end

  context "when the form is valid" do
    it "creates an amendment and the emendation" do
      expect { command.call }
      .to change(Decidim::Amendment, :count)
      .by(1)
      .and change(amendable.resource_manifest.model_class_name.constantize, :count)
      .by(1)
    end

    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "notifies the authors and followers of the amendable resource" do
      recipients = amendable.authors + amendable.followers
      command.call

      expect(Decidim::EventsManager)
      .to receive(:publish)
    end
  end
end
