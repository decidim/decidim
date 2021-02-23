# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionController::Base, type: :controller do
    let(:view) { controller.view_context }

    controller do
      include Decidim::Orderable

      def available_orders
        %w(random other)
      end
    end

    describe "#order" do
      let(:params) { {} }

      before do
        allow(controller).to receive(:params).and_return(params)
      end

      it "returns random order by default without the order parameter" do
        expect(view.order).to eq("random")
      end

      context "with random order given through params" do
        let(:params) { { order: "random" } }

        it "returns random order" do
          expect(view.order).to eq("random")
        end
      end

      context "with other order given through params" do
        let(:params) { { order: "other" } }

        it "returns other order" do
          expect(view.order).to eq("other")
        end
      end
    end

    describe "#random_seed" do
      it "creates a new random seed between -1..1 when not defined" do
        expect(view.random_seed).to be_a(Float)
        expect(view.random_seed).to be_between(-1, 1)
      end

      it "returns the same random seed for concecutive calls" do
        first_seed = view.random_seed
        expect(view.random_seed).to be(first_seed)
      end

      context "when the session defines the random seed" do
        let(:session) { { random_seed: test_seed } }
        let(:test_seed) { 0.123456789 }

        before do
          allow(controller).to receive(:session).and_return(session)
        end

        it "returns the random seed from the session variable" do
          expect(view.random_seed).to be(test_seed)
        end

        context "when the session variable is set as string" do
          let(:session) { { random_seed: test_seed.to_s } }

          it "returns the random seed as float from the session variable" do
            expect(view.random_seed).to be_a(Float)
            expect(view.random_seed).to be(test_seed)
          end
        end
      end
    end
  end
end
