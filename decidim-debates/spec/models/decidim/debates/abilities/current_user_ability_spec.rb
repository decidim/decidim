# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Abilities::CurrentUserAbility do
  subject { described_class.new(user, context) }

  let(:user) { build(:user) }
  let(:debates_component) { create :debates_component }
  let(:extra_context) do
    {
      current_settings: current_settings,
      component_settings: component_settings
    }
  end
  let(:context) do
    {
      current_component: debates_component
    }.merge(extra_context)
  end
  let(:settings) do
    {
      creation_enabled?: false
    }
  end
  let(:extra_settings) { {} }
  let(:component_settings) { {} }
  let(:current_settings) { double(settings.merge(extra_settings)) }

  describe "proposal creation" do
    it { is_expected.not_to be_able_to(:create, Decidim::Debates::Debate) }
    it { is_expected.to be_able_to(:report, Decidim::Debates::Debate) }

    context "when creation is enabled" do
      let(:extra_settings) { { creation_enabled: true } }

      it { is_expected.not_to be_able_to(:create, Decidim::Debates::Debate) }
    end
  end
end
