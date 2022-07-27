# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateArea do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:name) { Decidim::Faker::Localized.literal(Faker::Address.unique.state) }
    let(:code) { Faker::Address.unique.state_abbr }
    let(:area_type) { create :area_type }

    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        name:,
        organization:,
        area_type:
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

      it "creates a new area for the organization" do
        expect { subject.call }.to change { organization.areas.count }.by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::Area, user, hash_including(:name, :organization, :area_type))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
