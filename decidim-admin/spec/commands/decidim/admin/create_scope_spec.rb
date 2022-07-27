# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateScope do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:name) { Decidim::Faker::Localized.literal(Faker::Address.unique.state) }
    let(:code) { Faker::Address.unique.state_abbr }
    let(:scope_type) { create :scope_type }

    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        name:,
        organization:,
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
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a new scope for the organization" do
        expect { subject.call }.to change { organization.scopes.count }.by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::Scope,
            form.current_user,
            hash_including(:name, :organization, :code, :scope_type, :parent),
            hash_including(extra: hash_including(:parent_name, :scope_type_name))
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when its a child scope" do
        subject { described_class.new(form, parent_scope) }

        let!(:parent_scope) { create :scope, organization: }

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates a new scope for the organization" do
          expect { subject.call }.to change { organization.scopes.count }.by(1)
        end

        it "creates a child scope for the parent scope" do
          expect { subject.call }.to change { parent_scope.children.count }.by(1)
        end
      end
    end
  end
end
