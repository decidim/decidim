# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FeatureManifest do
    subject { described_class.new }

    describe "seed" do
      it "registers a block of seeds to be run on development" do
        data = {}
        subject.seeds do |_participatory_space|
          data[:foo] = :bar
        end

        subject.seed!(nil)

        expect(data[:foo]).to eq(:bar)
      end
    end

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
          expect(context[:bar]).not_to be
        end
      end

      describe "reset_hooks!" do
        it "resets hooks" do
          subject.on(:foo) do
            raise "Yo, I run!"
          end

          subject.reset_hooks!
          expect { subject.run_hooks(:foo) }.not_to raise_error
        end
      end
    end

    describe "register_stat" do
      before do
        allow(subject.stats).to receive(:register)
      end

      it "calls subject.stats with the same arguments" do
        resolver = proc { 10 }
        options = { primary: true }
        subject.register_stat :foo, options, &resolver
        expect(subject.stats).to have_received(:register).with(:foo, options, &resolver)
      end
    end

    describe "exports" do
      let(:collection1) { [{ id: 1 }, { id: 2 }] }
      let(:collection2) { [{ name: "ed" }, { name: "john" }] }
      let(:serializer) { Class.new }
      let(:manifests) { subject.export_manifests }

      before do
        subject.exports :foos do |exports|
          exports.collection { collection1 }
          exports.serializer serializer
        end

        subject.exports :bars do |exports|
          exports.collection { collection2 }
        end
      end

      describe "#export_manifests" do
        it "creates manifest instances" do
          expect(manifests[0]).to be_kind_of(Decidim::Features::ExportManifest)
          expect(manifests[1]).to be_kind_of(Decidim::Features::ExportManifest)
        end

        it "initializes instances properly" do
          expect(manifests[0].name).to eq(:foos)
          expect(manifests[1].name).to eq(:bars)
        end

        it "passes through the manifest instance as block parameter" do
          expect(manifests[0].collection.call).to eq(collection1)
          expect(manifests[1].collection.call).to eq(collection2)
        end
      end
    end
  end
end
