# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::UpdateDebate do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "debates" }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:user) { create :user, organization: organization }
  let(:author) { user }
  let!(:debate) { create :debate, author: author, component: current_component }
  let(:form) do
    Decidim::Debates::DebateForm.from_params(
      title: "title",
      description: "description",
      scope_id: scope.id,
      category_id: category.id,
      id: debate.id
    ).with_context(
      current_organization: organization,
      current_participatory_space: current_component.participatory_space,
      current_component: current_component,
      current_user: user
    )
  end

  describe "when the form is not valid" do
    before do
      allow(form).to receive(:invalid?).and_return(true)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "doesn't update the debate" do
      expect do
        subject.call
        debate.reload
      end.not_to change(debate, :title)
    end
  end

  describe "when the debate is not editable by the user" do
    let(:author) { create :user, organization: organization }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "doesn't update the debate" do
      expect do
        subject.call
        debate.reload
      end.not_to change(debate, :title)
    end
  end

  context "when everything is ok" do
    it "updates the debate" do
      expect do
        subject.call
        debate.reload
      end.to change(debate, :title)
    end

    it "sets the scope" do
      subject.call
      debate.reload
      expect(debate.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      debate.reload
      expect(debate.category).to eq category
    end

    it "sets the title with i18n" do
      subject.call
      debate.reload
      expect(debate.title.except("machine_translations").values.uniq).to eq ["title"]
    end

    it "sets the description with i18n" do
      subject.call
      debate.reload
      expect(debate.description.except("machine_translations").values.uniq).to eq ["description"]
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:update!)
        .with(
          Decidim::Debates::Debate,
          user,
          hash_including(:category, :title, :description),
          visibility: "public-only"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "update"
    end
  end
end
