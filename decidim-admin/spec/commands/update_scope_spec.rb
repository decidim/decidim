require "spec_helper"

describe Decidim::Admin::UpdateScope do
  let(:organization) { create :organization }
  let(:scope) { create :scope, organization: organization }
  let(:name) { "My scope"}
  let(:form) do
    double(
      :invalid? => invalid,
      name: name
    )
  end
  let(:invalid) { false }

  subject { described_class.new(scope, form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
