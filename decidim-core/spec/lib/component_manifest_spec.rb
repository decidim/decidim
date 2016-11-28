require "spec_helper"

module Decidim
  describe ComponentManifest do
    subject { described_class.new }

    describe "hooks" do
      describe "run_hooks" do
        it "runs all registered hooks" do
          subject.on(:foo) do |context|
            context[:foo_1] ||= 0
            context[:foo_1] += 1
          end

          subject.on(:foo) do |context|
            context[:foo_2] ||= 0
            context[:foo_2] += 1
          end

          subject.on(:bar) do
            context[:bar] ||= 0
            context[:bar] += 1
          end

          context = {}
          subject.run_hooks(:foo, context)
          expect(context[:foo_1]).to eq(1)
          expect(context[:foo_2]).to eq(1)
          expect(context[:bar]).to_not be
        end
      end

      describe "reset_hooks!" do
        it "resets hooks" do
          subject.on(:foo) do
            raise "Yo, I run!"
          end

          subject.reset_hooks!
          expect { subject.run_hooks(:foo) }.to_not raise_error
        end
      end
    end
  end
end
