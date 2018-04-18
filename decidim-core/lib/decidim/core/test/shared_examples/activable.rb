# frozen_string_literal: true

require "spec_helper"

shared_examples_for "activable" do
  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }

  let(:active) do
    create(factory_name, :active)
  end

  let(:inactive) do
    create(factory_name)
  end

  describe ".active" do
    let(:scope) { described_class.active }

    before { active && inactive }

    it { expect(scope).to eq([active]) }
  end

  describe ".inactive" do
    let(:scope) { described_class.inactive }

    before { active && inactive }

    it { expect(scope).to eq([inactive]) }
  end
end
