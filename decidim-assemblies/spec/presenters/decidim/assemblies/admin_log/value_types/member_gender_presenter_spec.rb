# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::AdminLog::ValueTypes::MemberGenderPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { Decidim::AssemblyMember::GENDERS.sample }

  describe "#present" do
    it "renders the translated value" do
      expect(subject.present).to eq t(value, scope: "decidim.admin.models.assembly_member.genders")
    end
  end
end
