# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizeUser do
    let(:user) { create(:user) }
    let(:document_number) { "12345678X" }
    let(:handler) do
      DummyAuthorizationHandler.new(
        document_number: document_number,
        user: user
      )
    end

    subject { described_class.new(handler) }

    context "when the form is not authorized" do
      before do
        expect(handler).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates an authorization for the user" do
        expect { subject.call }.to change { user.authorizations.count }.by(1)
      end

      it "stores the metadata" do
        subject.call

        expect(user.authorizations.first.metadata["document_number"]).to eq("12345678X")
      end
    end

    describe "uniqueness" do
      let(:user) { create(:user) }
      let(:unique_id) { "foo" }

      context "when there's no other authorizations" do
        it "is valid if there's no authorization with the same id" do
          expect { subject.call }.to change { user.authorizations.count }.by(1)
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
          expect { subject.call }.to change { user.authorizations.count }.by(0)
        end
      end
    end
  end
end
