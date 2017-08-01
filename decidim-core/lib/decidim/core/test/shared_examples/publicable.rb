# frozen_string_literal: true

require "spec_helper"

shared_examples_for "publicable" do
  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }

  let!(:published) do
    create(factory_name, published_at: Time.zone.now)
  end

  let!(:unpublished) do
    create(factory_name, published_at: nil)
  end

  describe ".published" do
    let(:scope) { described_class.send(:published) }

    it { expect(scope).to eq([published]) }
  end

  describe ".unpublished" do
    let(:scope) { described_class.send(:unpublished) }

    it { expect(scope).to eq([unpublished]) }
  end
end
