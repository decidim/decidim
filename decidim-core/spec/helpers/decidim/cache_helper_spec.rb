# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CacheHelper do
    describe "#cache" do
      let(:helper) do
        helper_class = described_class
        parent_helper = parent

        # Define the "original" cache method that is called through super.
        # Normally this would be ActionView::Helpers::CacheHelper#cache but we
        # override it to test what is actually received.
        original = Module.new
        original.define_method(:cache) do |name = {}, options = {}, &block|
          parent_helper.send(:cache, name, options, &block)
        end

        # Define the final helper which is extended with the "original" helper
        # and the helper class to be tested.
        final = Class.new.tap do |v|
          v.extend(original)
          v.extend(helper_class)
        end
        allow(final).to receive(:current_locale).and_return(locale)

        final
      end
      let(:parent) { double }
      let(:name) { double }
      let(:locale) { "en" }
      let(:block) { -> {} }

      it "calls the original method and with the locale added to the name" do
        expect(parent).to receive(:cache) do |received_name, received_options, &received_block|
          expect(received_name).to eq([name, locale])
          expect(received_options).to eq({})
          expect(received_block).to be(block)
        end

        helper.cache(name, &block)
      end
    end
  end
end
