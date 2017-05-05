# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::CreateScope do
  let(:organization) { create :organization }
  let(:name) { "My scope" }
  let(:form) do
    double(
      invalid?: invalid,
      name: name,
      organization: organization
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
