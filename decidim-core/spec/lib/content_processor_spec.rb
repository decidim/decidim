# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentProcessor do
    before do
      allow(Decidim).to receive(:content_processors).and_return([:dummy_foo, :dummy_bar])
    end

    let(:context) { {} }
    let(:processor) { ContentProcessor }

    describe "#parse" do
      subject { processor.parse("This text contains foo and bar and another foo", context) }

      it "executes all registered parsers" do
        expect(subject.rewrite).to eq("This text contains %lorem% and *ipsum* and another %lorem%")
        expect(subject.metadata).to eq(dummy_foo: 2, dummy_bar: 1)
      end
    end

    describe "#parse_with_processor" do
      subject { processor.parse_with_processor(:dummy_foo, content, context) }

      let(:content) { "This text contains foo and bar and another foo" }

      it "executes only the given processor" do
        expect(subject.rewrite).to eq("This text contains %lorem% and bar and another %lorem%")
        expect(subject.metadata).to eq(dummy_foo: 2)
      end

      context "when the content has translations" do
        let(:content) do
          {
            "en" => "This text contains foo and bar and another foo",
            "ca" => "This text contains foo and bar and another foo in catalan"
          }
        end

        it "handles it too" do
          expect(subject.rewrite).to eq(
            "en" => "This text contains %lorem% and bar and another %lorem%",
            "ca" => "This text contains %lorem% and bar and another %lorem% in catalan"
          )
          expect(subject.metadata).to eq(dummy_foo: 2)
        end
      end

      context "when the content has machine translations" do
        let(:content) do
          {
            "en" => "This text contains foo and bar and another foo",
            "machine_translations" => {
              "ca" => "This text contains foo and bar and another foo in catalan"
            }
          }
        end

        it "handles it too" do
          expect(subject.rewrite).to eq(
            "en" => "This text contains %lorem% and bar and another %lorem%",
            "machine_translations" => {
              "ca" => "This text contains %lorem% and bar and another %lorem% in catalan"
            }
          )
          expect(subject.metadata).to eq(dummy_foo: 2)
        end
      end
    end

    describe "#render" do
      subject { processor.render("This text contains %lorem% and *ipsum* and another %lorem%") }

      it "executes all registered parsers" do
        expect(subject).to eq("<p>This text contains <em>neque dicta enim quasi</em> and <em>illo qui voluptas</em> and another <em>neque dicta enim quasi</em></p>")
      end
    end

    describe "#render_without_format" do
      subject { processor.render_without_format("This text contains %lorem% and *ipsum* and another %lorem%") }

      it "renders the content without extra formatting" do
        expect(subject).to eq("This text contains <em>neque dicta enim quasi</em> and <em>illo qui voluptas</em> and another <em>neque dicta enim quasi</em>")
      end
    end
  end
end
