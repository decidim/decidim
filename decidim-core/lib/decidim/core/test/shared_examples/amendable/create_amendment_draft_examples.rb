# frozen_string_literal: true

shared_examples "create amendment draft" do
  context "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "creates an amendment (draft) and the emendation (not published)" do
      expect { command.call }
        .to change(Decidim::Amendment, :count)
        .by(1)
        .and change(amendable.class, :count)
        .by(1)

      expect(Decidim::Amendment.last.draft?).to eq(true)
      expect(amendable.class.last.published?).to eq(false)
    end

    it "traces the action without creating a PaperTrail version for the emendation", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          :create,
          amendable.class,
          form.current_user,
          kind_of(Hash)
        ).and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
      expect(amendable.class.last.versions.count).to eq(0)
    end
  end

  context "when the form is invalid" do
    let(:title) { "Too short" }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end

    it "doesn't create an amendment and the emendation" do
      expect { command.call }
        .to change(Decidim::Amendment, :count)
        .by(0)
        .and change(amendable.class, :count)
        .by(0)
    end
  end
end
