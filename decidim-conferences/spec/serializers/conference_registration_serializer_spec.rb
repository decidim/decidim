# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceRegistrationSerializer do
    let(:conference_registration) { create(:conference_registration) }
    let(:subject) { described_class.new(conference_registration) }

    describe "#serialize" do
      it "includes the id" do
        expect(subject.serialize).to include(id: conference_registration.id)
      end

      it "includes the user" do
        expect(subject.serialize[:user]).to(
          include(name: conference_registration.user.name)
        )
        expect(subject.serialize[:user]).to(
          include(email: conference_registration.user.email)
        )
      end
    end
  end
end
