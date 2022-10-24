# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateAreaType do
    subject { described_class.new(form, user) }

    let(:organization) { create :organization }
    let(:user) { create(:user, organization:) }
    let(:name) { Decidim::Faker::Localized.literal("territorial") }
    let(:plural) { Decidim::Faker::Localized.literal("territorials") }

    let(:form) do
      double(
        invalid?: invalid,
        name:,
        organization:,
        plural:
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a new scope type for the organization" do
        expect { subject.call }.to change { organization.area_types.count }.by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::AreaType, user, {})
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("create")
        expect(action_log.version).to be_present
      end
    end
  end
end
