# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe DestroyUserAuthorization do
    subject { described_class.new(authorization) }

    let(:user) { create(:user, :confirmed) }

    let(:authorizations) { Authorizations.new(organization: user.organization, user:, granted: true) }

    context "when no authorization" do
      let(:authorization) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let!(:authorization) { create(:authorization, :granted, user:) }

      it "destroys the authorization for the user" do
        expect { subject.call }.to change(authorizations, :count).by(-1)
      end
    end
  end
end
