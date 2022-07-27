# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateArea do
    subject { described_class.new(area, form) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:area) { create :area, organization: }
    let(:name) { Decidim::Faker::Localized.literal("New name") }
    let(:area_type) { create :area_type, organization: }

    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        name:,
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
      before do
        subject.call
        area.reload
      end

      it "updates the name of the area" do
        expect(translated(area.name)).to eq("New name")
      end

      it "updates the area type" do
        expect(area.area_type).to eq(area_type)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(area, user, hash_including(:name, :area_type))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
