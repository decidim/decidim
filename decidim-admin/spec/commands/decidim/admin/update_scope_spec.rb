# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateScope do
    subject { described_class.new(scope, form) }

    let(:organization) { create :organization }
    let(:parent_scope) { create :scope, organization: }
    let(:scope) { create :scope, parent: parent_scope, organization: }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:name) { Decidim::Faker::Localized.literal("New name") }
    let(:code) { "NEWCODE" }
    let(:scope_type) { create :scope_type, organization: }

    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        name:,
        code:,
        scope_type:
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
      it "updates the name of the scope" do
        subject.call
        scope.reload
        expect(translated(scope.name)).to eq("New name")
      end

      it "updates the code of the scope" do
        subject.call
        scope.reload
        expect(scope.code).to eq("NEWCODE")
      end

      it "updates the scope type" do
        subject.call
        scope.reload
        expect(scope.scope_type).to eq(scope_type)
      end

      it "keeps the parent scope" do
        expect(scope.parent).to eq(parent_scope)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(
            scope,
            form.current_user,
            hash_including(:name, :code, :scope_type),
            hash_including(extra: hash_including(:parent_name, :scope_type_name))
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
