# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::CreateStatus do
    subject { described_class.new(form, user) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:user) { create(:user, organization: organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, manifest_name: "accountability", participatory_space: participatory_process }

    let(:key) { "planned" }
    let(:name) { "Planned" }
    let(:description) { "description" }
    let(:progress) { 75 }

    let(:form) do
      double(
        invalid?: invalid,
        current_component: current_component,
        key: key,
        name: { en: name },
        description: { en: description },
        progress: progress
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:status) { Status.last }

      it "creates the status" do
        expect { subject.call }.to change(Status, :count).by(1)
      end

      it "sets the name" do
        subject.call
        expect(translated(status.name)).to eq name
      end

      it "sets the description" do
        subject.call
        expect(translated(status.description)).to eq description
      end

      it "sets the key" do
        subject.call
        expect(status.key).to eq key
      end

      it "sets the progress" do
        subject.call
        expect(status.progress).to eq progress
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Accountability::Status, user, {})
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("create")
        expect(action_log.version).to be_present
      end
    end
  end
end
