# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateScopeType do
    subject { described_class.new(scope_type, form, user) }

    let(:organization) { create :organization }
    let(:user) { create(:user, organization:) }
    let(:scope_type) { create :scope_type, organization: }
    let(:name) { Decidim::Faker::Localized.literal("new name") }
    let(:plural) { Decidim::Faker::Localized.literal("new names") }

    let(:form) do
      double(
        invalid?: invalid,
        name:,
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
      before do
        subject.call
        scope_type.reload
      end

      it "updates the name of the scope" do
        expect(translated(scope_type.name)).to eq("new name")
      end

      it "updates the plural of the scope" do
        expect(translated(scope_type.plural)).to eq("new names")
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:update, scope_type, user, {})
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("update")
        expect(action_log.version).to be_present
      end
    end
  end
end
