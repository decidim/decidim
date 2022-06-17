# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe AuthorizeUser do
    subject { described_class.new(handler, organization) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed) }
    let(:document_number) { "12345678X" }
    let(:handler) do
      DummyAuthorizationHandler.new(
        document_number:,
        user:
      )
    end

    let(:authorizations) { Authorizations.new(organization: user.organization, user:, granted: true) }

    context "when the form is not authorized" do
      before do
        allow(handler).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates an authorization for the user" do
        expect { subject.call }.to change(authorizations, :count).by(1)
      end

      it "stores the metadata" do
        subject.call

        expect(authorizations.first.metadata["document_number"]).to eq("12345678X")
      end

      it "sets the authorization as granted" do
        subject.call

        expect(authorizations.first).to be_granted
      end
    end

    describe "uniqueness" do
      let(:unique_id) { "foo" }

      context "when there's no other authorizations" do
        it "is valid if there's no authorization with the same id" do
          expect { subject.call }.to change(authorizations, :count).by(1)
        end
      end

      context "when there's other authorizations" do
        let!(:other_user) { create(:user, organization: user.organization) }

        before do
          create(:authorization,
                 user: other_user,
                 unique_id: document_number,
                 name: handler.handler_name)
        end

        it "is invalid if there's another authorization with the same id" do
          expect { subject.call }.to change(authorizations, :count).by(0)
        end
      end
    end

    describe "managed user" do
      context "when document_id was used by a managed user" do
        let!(:other_user) { create(:user, managed: true, organization: user.organization) }

        before do
          create(:authorization,
                 user: other_user,
                 unique_id: document_number,
                 name: handler.handler_name)
        end

        it "saves conflicts" do
          expect { subject.call }.to change(Decidim::Verifications::Conflict, :count).by(1)
        end

        it "increases conflicts times" do
          subject.call

          conflict = Decidim::Verifications::Conflict.last

          expect(conflict.times).to eq(1)

          subject.call

          expect(conflict.reload.times).to eq(2)
        end

        it "sends notification to admins" do
          allow(Decidim::EventsManager).to receive(:publish).and_call_original
          subject.call

          conflict = Decidim::Verifications::Conflict.last

          expect(Decidim::EventsManager).to have_received(:publish).with(
            event: "decidim.events.verifications.managed_user_error_event",
            event_class: Decidim::Verifications::ManagedUserErrorEvent,
            resource: conflict,
            affected_users: Decidim::User.where(admin: true, organization:)
          )
        end
      end
    end
  end
end
