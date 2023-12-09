# frozen_string_literal: true

require "spec_helper"

describe Decidim::Commands::DestroyResource do
  context "when the resource is a page" do
    subject { described_class.new(page, user) }

    let!(:page) { create(:static_page) }
    let!(:user) { create(:user, organization: page.organization) }

    context "when everything is ok" do
      it "destroys the page" do
        subject.call
        expect(Decidim::StaticPage.where(id: page.id)).not_to exist
      end

      it "logs the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", page, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end

  context "when the resource is an newsletter" do
    subject { described_class.new(newsletter, user) }

    let(:newsletter) { create(:newsletter) }
    let(:user) { create(:user, organization: newsletter.organization) }

    context "when the newsletter is already sent" do
      let(:newsletter) { create(:newsletter, :sent) }

      it "does not destroy the newsletter" do
        subject.call
        expect(Decidim::Newsletter.where(id: newsletter.id)).to exist
      end

      it "broadcasts :already_sent" do
        expect { subject.call }.to broadcast(:already_sent)
      end
    end

    context "when everything is ok" do
      it "destroys the newsletter" do
        subject.call
        expect(Decidim::Newsletter.where(id: newsletter.id)).not_to exist
      end

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "logs the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", newsletter, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end

  context "when the resource is an area" do
    subject { described_class.new(area, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:area) { create(:area, organization:) }

    it "destroys the area" do
      subject.call
      expect { area.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "delete",
          area,
          user
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
