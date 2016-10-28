# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe Ability do
    let(:user) { build(:user) }
    let(:abilities) { [] }

    subject { described_class.new(user) }

    let(:ability_class) do
      Class.new do
        include CanCan::Ability

        def initialize(user)
          can :read, Decidim::ParticipatoryProcess
        end
      end
    end

    before do
      allow(Decidim)
        .to receive(:abilities)
        .and_return(abilities)
    end

    it "does not hold any special ability" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end

    context "when there are some abilities injected from configuration" do
      let(:abilities) { [ability_class] }

      it "applies the injected abilities" do
        expect(subject).to be_able_to(:read, Decidim::ParticipatoryProcess)
      end
    end
  end
end
