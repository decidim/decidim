# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe DownloadYourDataConferenceInviteSerializer do
    let(:resource) { build_stubbed(:conference_invite) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the invite data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(subject.serialize).to include(id: resource.id)
        expect(subject.serialize).to include(sent_at: resource.sent_at)
        expect(subject.serialize).to include(accepted_at: resource.accepted_at)
        expect(subject.serialize).to include(rejected_at: resource.rejected_at)
      end

      it "includes the user" do
        serialized_user = subject.serialize[:user]

        expect(serialized_user).to be_a(Hash)

        expect(serialized_user).to include(name: resource.user.name)
        expect(serialized_user).to include(email: resource.user.email)
      end

      it "includes the registration_type" do
        serialized_registration_type = subject.serialize[:registration_type]

        expect(serialized_registration_type).to be_a(Hash)

        expect(serialized_registration_type).to include(title: resource.registration_type.title)
        expect(serialized_registration_type).to include(price: resource.registration_type.price)
      end

      it "includes the conference" do
        serialized_conference = subject.serialize[:conference]

        expect(serialized_conference).to be_a(Hash)

        expect(serialized_conference).to include(title: resource.conference.title)
        expect(serialized_conference).to include(slogan: resource.conference.slogan)
        expect(serialized_conference).to include(description: resource.conference.description)
        expect(serialized_conference).to include(start_date: resource.conference.start_date)
        expect(serialized_conference).to include(end_date: resource.conference.end_date)
        expect(serialized_conference).to include(location: resource.conference.location)
        expect(serialized_conference).to include(reference: resource.conference.reference)
      end
    end
  end
end
