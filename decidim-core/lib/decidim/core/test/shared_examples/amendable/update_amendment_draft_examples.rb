# frozen_string_literal: true

shared_examples "update amendment draft" do
  describe "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "updates the emendation without creating a PaperTrail version" do
      expect { command.call }
        .to change(form.emendation, :title)
        .and change(form.emendation, :body)
      expect(amendable.class.last.versions.count).to eq(0)
    end
  end

  describe "when the form is not valid" do
    let(:title) { "Too short" }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end

  describe "when the current user is not the amender" do
    let(:current_user) { other_user }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end

  describe "when the amendment is not a draft" do
    before do
      amendment.update(state: "evaluating")
    end

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end
end
