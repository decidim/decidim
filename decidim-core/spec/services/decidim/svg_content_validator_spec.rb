# frozen_string_literal: true

require "spec_helper"

describe Decidim::SvgContentValidator do
  describe ".validate" do
    subject(:validation) { described_class.validate(content) }

    shared_examples "a valid SVG document" do
      it "returns :valid" do
        expect(validation).to eq(:valid)
      end
    end

    shared_examples "an unsafe SVG document" do
      it "returns :unsafe" do
        expect(validation).to eq(:unsafe)
      end
    end

    shared_examples "an invalid SVG document" do
      it "returns :invalid" do
        expect(validation).to eq(:invalid)
      end
    end

    context "with a plain SVG document" do
      let(:content) { File.read(Decidim::Dev.asset("test.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG with a prolog, a DTD and embedded content" do
      let(:content) { File.read(Decidim::Dev.asset("test_complex.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG with a declarative animation" do
      let(:content) { File.read(Decidim::Dev.asset("test_animation.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose style sheet mentions resource references only in quoted text" do
      let(:content) { File.read(Decidim::Dev.asset("test_style_text.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG referencing the document itself, relative paths and inline data" do
      let(:content) { File.read(Decidim::Dev.asset("test_references.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG document with active content" do
      %w(
        malicious_svg_script.svg
        malicious_svg_handler.svg
        malicious_svg_uri.svg
        malicious_svg_foreign_object.svg
        malicious_svg_animation.svg
        malicious_svg_animation_values.svg
        malicious_svg_style_import.svg
        malicious_svg_style_import_string.svg
        malicious_svg_style_url_string.svg
        malicious_svg_style_url_escape.svg
        malicious_svg_style_comment_string.svg
        malicious_svg_stylesheet_pi.svg
        malicious_svg_entity.svg
        malicious_svg_external_image.svg
        malicious_svg_external_use.svg
        malicious_svg_external_feimage.svg
        malicious_svg_external_animation.svg
      ).each do |file|
        context "with #{file}" do
          let(:content) { File.read(Decidim::Dev.asset(file)) }

          it_behaves_like "an unsafe SVG document"
        end
      end
    end

    context "when the contents are blank" do
      let(:content) { "" }

      it_behaves_like "an invalid SVG document"
    end

    context "when the contents are nil" do
      let(:content) { nil }

      it_behaves_like "an invalid SVG document"
    end

    context "with an XML document which is not an SVG" do
      let(:content) { File.read(Decidim::Dev.asset("spoofed_svg_xml.svg")) }

      it_behaves_like "an invalid SVG document"
    end
  end
end
