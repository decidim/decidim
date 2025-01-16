# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe DownloadYourDataConferenceRegistrationSerializer do
    let(:resource) { create(:conference_registration) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the registration metadata" do
        expect(subject.serialize).to include(id: resource.id)
        expect(subject.serialize).to include(created_at: resource.created_at)
        expect(subject.serialize).to include(updated_at: resource.updated_at)
        expect(subject.serialize).to include(confirmed_at: resource.confirmed_at)
      end

      it "includes the registration_type" do
        expect(subject.serialize[:registration_type]).to(
          include(title: resource.registration_type.title)
        )
        expect(subject.serialize[:registration_type]).to(
          include(price: resource.registration_type.price)
        )
      end

      it "includes the conference" do
        expect(subject.serialize[:conference]).to(
          include(url: Decidim::EngineRouter.main_proxy(resource.conference).conference_url(resource.conference))
        )

        expect(subject.serialize[:conference]).to(
          include(title: resource.conference.title)
        )

        expect(subject.serialize[:conference]).to(
          include(slogan: resource.conference.slogan)
        )

        expect(subject.serialize[:conference]).to(
          include(description: resource.conference.description)
        )

        expect(subject.serialize[:conference]).to(
          include(reference: resource.conference.reference)
        )

        expect(subject.serialize[:conference]).to(
          include(start_date: resource.conference.start_date)
        )

        expect(subject.serialize[:conference]).to(
          include(end_date: resource.conference.end_date)
        )

        expect(subject.serialize[:conference]).to(
          include(location: resource.conference.location)
        )
      end
    end
  end
end
