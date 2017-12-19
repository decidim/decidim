# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe OfficializeUser do
    subject { described_class.new(form) }

    let(:organization) { create :organization }

    let(:form) do
      OfficializationForm.from_params(
        officialized_as: { "en" => "Major of Barcelona" },
        user_id: user_id
      ).with_context(
        current_organization: organization
      )
    end

    context "when the form is not valid" do
      let(:user_id) { "37" }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "does not officialize users" do
        subject.call

        expect { subject.call }.not_to change { Decidim::User.where(officialized_at: nil).count }
      end
    end

    context "when the form is valid" do
      let(:user) { create(:user, organization: organization) }

      let(:user_id) { user.id }

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "officializes user" do
        subject.call

        expect(user.reload).to be_officialized
      end
    end
  end
end
