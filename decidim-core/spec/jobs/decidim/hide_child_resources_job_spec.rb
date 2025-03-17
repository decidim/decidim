# frozen_string_literal: true

require "spec_helper"

describe Decidim::HideChildResourcesJob do
  subject { described_class }

  let!(:organization) { create(:organization) }

  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:component) { create(:dummy_component, participatory_space:) }
  let!(:resource) { create(:dummy_resource, component:) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "user_report"
    end
  end

  describe "perform" do
    context "when spam reporting user exists" do
      let(:user) { create(:user, :admin, organization:, email: "reporting_user@example.org") }

      it "hides the resource" do
        subject.perform_now(resource, user.id)
        expect(resource).to be_hidden
      end
    end

    context "when spam reporting user does not exist" do
      let(:user) { create(:user, :admin, organization:) }

      it "hides the resource" do
        subject.perform_now(resource, user.id)

        expect(resource).to be_hidden
      end
    end
  end
end
