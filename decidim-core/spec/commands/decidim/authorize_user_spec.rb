require "spec_helper"

module Decidim
  describe AuthorizeUser do
    let(:user) { create(:user) }
    let(:handler) do
      DummyAuthorizationHandler.new(
        document_number: "12345678X",
        user: user
      )
    end

    before do
      expect(handler).to receive(:authorized?).and_return(authorized)
    end

    subject { described_class.new(handler) }

    context "when the form is not authorized" do
      let(:authorized) { false }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:authorized) { true }

      it "creates an authorization for the user" do
        expect { subject.call }.to change { user.authorizations.count }.by(1)
      end

      it "stores the metadata" do
        subject.call

        expect(user.authorizations.first.metadata["document_number"]).to eq("12345678X")
      end
    end
  end
end
