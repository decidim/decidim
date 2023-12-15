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
          .with(:delete, page, user)
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
          :delete,
          area,
          user
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end

  context "when the resource is an area type" do
    subject { described_class.new(area_type, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:area_type) { create(:area_type, organization:) }

    it "destroys the area" do
      subject.call
      expect { area_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
          :delete,
          area_type,
          user
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end

  context "when the resource is an scope type" do
    subject { described_class.new(scope_type, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:scope_type) { create(:scope_type, organization:) }

    it "destroys the area" do
      subject.call
      expect { scope_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
          :delete,
          scope_type,
          user
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
