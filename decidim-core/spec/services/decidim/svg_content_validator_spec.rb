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

    context "with an SVG with an animation assigning external links" do
      let(:content) { File.read(Decidim::Dev.asset("test_animation_link.svg")) }

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

    context "with an SVG whose inline data reference declares its own encoding" do
      let(:content) { File.read(Decidim::Dev.asset("test_data_uri_declared_encoding.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose entity declarations only appear inside comments and CDATA sections" do
      let(:content) { File.read(Decidim::Dev.asset("test_entity_in_comment.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose entity declaration only appears inside a processing instruction" do
      let(:content) { File.read(Decidim::Dev.asset("test_entity_in_processing_instruction.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose animation target reference is percent encoded" do
      let(:content) { File.read(Decidim::Dev.asset("test_percent_encoded_fragment.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose animation target reference decodes to a multi-byte identifier" do
      let(:content) { File.read(Decidim::Dev.asset("test_percent_encoded_multibyte_reference.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose animation target reference mixes multi-byte characters with percent encoded ones" do
      let(:content) { File.read(Decidim::Dev.asset("test_percent_encoded_multibyte_reference_mixed.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose style sheet references only elements of the document" do
      let(:content) { File.read(Decidim::Dev.asset("test_css_references.svg")) }

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
        malicious_svg_animation_style.svg
        malicious_svg_animation_attribute_names.svg
        malicious_svg_attributename_case.svg
        malicious_svg_style_import.svg
        malicious_svg_style_import_string.svg
        malicious_svg_style_url_string.svg
        malicious_svg_style_url_escape.svg
        malicious_svg_style_comment_string.svg
        malicious_svg_css_comment_in_url.svg
        malicious_svg_css_backslash_url.svg
        malicious_svg_css_image_set.svg
        malicious_svg_css_image_set_nested_parentheses.svg
        malicious_svg_mask_attribute.svg
        malicious_svg_cursor_attribute.svg
        malicious_svg_stylesheet_pi.svg
        malicious_svg_entity.svg
        malicious_svg_entity_parameter.svg
        malicious_svg_data_uri_nested.svg
        malicious_svg_data_uri_parameter.svg
        malicious_svg_data_uri_leading_space.svg
        malicious_svg_data_uri_deep_nested.svg
        malicious_svg_data_uri_declared_encoding.svg
        malicious_svg_external_image.svg
        malicious_svg_external_use.svg
        malicious_svg_external_feimage.svg
        malicious_svg_cursor.svg
        malicious_svg_backslash_reference.svg
        malicious_svg_external_animation.svg
        malicious_svg_external_animation_target.svg
        malicious_svg_external_animation_missing_target.svg
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

    context "with a malformed SVG document with an unclosed element" do
      let(:content) { File.read(Decidim::Dev.asset("malformed_svg_unclosed_element.svg")) }

      it_behaves_like "an invalid SVG document"
    end
  end
end
