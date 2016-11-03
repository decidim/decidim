# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::Abilities::AdminUser do
  let(:user) { build(:user, :admin) }

  subject { described_class.new(user) }

  context "when the user is not an admin" do
    let(:user) { build(:user) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it "can manage processes" do
    expect(subject.permissions[:can][:manage]).to include("Decidim::ParticipatoryProcess")
  end

  it "can manage process steps" do
    expect(subject.permissions[:can][:manage]).to include("Decidim::ParticipatoryProcessStep")
  end
end
