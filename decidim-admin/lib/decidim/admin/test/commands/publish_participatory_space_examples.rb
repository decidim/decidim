# frozen_string_literal: true

require "spec_helper"

shared_examples "Publicable space" do |participatory_manifest_name|
  let(:tested) { Decidim::Admin::ParticipatorySpace::Publish }
  subject { tested.new(participatory_space, user) }
  let(:space_options) { {} }

  let(:participatory_space) { create(participatory_manifest_name, :unpublished, organization: user.organization, **space_options) }
  let(:user) { create(:user) }
  let(:default_options) { { visibility: "all" } }

  context "when the process is nil" do
    let(:participatory_space) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is published" do
    let(:participatory_space) { create(participatory_manifest_name) }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is not published" do
    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:publish, participatory_space, user, **default_options)
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "update"
    end

    it "publishes it" do
      subject.call
      participatory_space.reload
      expect(participatory_space).to be_published
    end
  end
end

shared_examples "Unpublicable space" do |participatory_manifest_name|
  subject { Decidim::Admin::ParticipatorySpace::Unpublish.new(participatory_space, user) }

  let(:participatory_space) { create(participatory_manifest_name, :published, organization: user.organization) }
  let(:user) { create(:user) }

  context "when the process is nil" do
    let(:participatory_space) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is not published" do
    let(:participatory_space) { create(participatory_manifest_name, :unpublished) }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is published" do
    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:unpublish, participatory_space, user, visibility: "all")
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "update"
    end

    it "unpublishes it" do
      subject.call
      participatory_space.reload
      expect(participatory_space).not_to be_published
    end
  end
end
