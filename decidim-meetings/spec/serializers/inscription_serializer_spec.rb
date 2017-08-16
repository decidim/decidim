# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::InscriptionSerializer do
  let(:inscription) { create(:inscription) }
  let(:subject) { described_class.new(inscription) }

  describe "#serialize" do
    it "includes the id" do
      expect(subject.serialize).to include(id: inscription.id)
    end

    it "includes the user" do
      expect(subject.serialize[:user]).to(
        include(name: inscription.user.name)
      )
      expect(subject.serialize[:user]).to(
        include(name: inscription.user.email)
      )
    end
  end
end
