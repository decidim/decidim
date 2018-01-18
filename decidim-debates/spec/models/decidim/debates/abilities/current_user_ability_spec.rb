# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Abilities::CurrentUserAbility do
  subject { described_class.new(user, context) }

  let(:user) { build(:user) }
  let(:debates_feature) { create :debates_feature }
  let(:extra_context) do
    {
      current_settings: current_settings,
      feature_settings: feature_settings
    }
  end
  let(:context) do
    {
      current_feature: debates_feature
    }.merge(extra_context)
  end
  let(:settings) do
    {
      creation_enabled?: false
    }
  end
  let(:extra_settings) { {} }
  let(:feature_settings) { {} }
  let(:current_settings) { double(settings.merge(extra_settings)) }

  describe "proposal creation" do
    it { is_expected.to be_able_to(:create, Decidim::Debates::Debate) }
  end
end
