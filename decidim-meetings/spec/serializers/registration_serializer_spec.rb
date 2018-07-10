# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe RegistrationSerializer do
    let(:registration) { create(:registration) }
    let(:subject) { described_class.new(registration) }

    describe "#serialize" do
      it "includes the id" do
        expect(subject.serialize).to include(id: registration.id)
      end

      it "includes the registration code" do
        expect(subject.serialize).to include(code: registration.code)
      end

      it "includes the user" do
        expect(subject.serialize[:user]).to(
          include(name: registration.user.name)
        )
        expect(subject.serialize[:user]).to(
          include(email: registration.user.email)
        )
      end
    end
  end
end
