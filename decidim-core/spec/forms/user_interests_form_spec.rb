# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserInterestsForm do
    subject { described_class.new(scopes:) }
    let(:scopes) { [] }

    describe ".from_model" do
      subject { described_class.from_model(user) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:, extended_data: { "interested_scopes" => scopes[0..1].map(&:id) }) }
      let(:scopes) { create_list(:scope, 5, organization:) }

      it "sets the organization scopes for the form" do
        expect(subject.scopes.count).to eq(5)
        expect(subject.scopes.select(&:checked).map(&:id).sort).to eq(user.interested_scopes_ids.sort)
      end
    end
  end
end
