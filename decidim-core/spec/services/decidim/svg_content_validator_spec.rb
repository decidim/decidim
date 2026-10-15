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

    context "with an SVG whose reference is resolved from the root of the origin serving the document" do
      let(:content) { File.read(Decidim::Dev.asset("test_root_relative_reference.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose link references an inline document, which the browsers of the readers do not open as a top-level document" do
      let(:content) { File.read(Decidim::Dev.asset("test_link_data_document.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose link uses a scheme which does not fetch a resource when the document is rendered" do
      let(:content) { File.read(Decidim::Dev.asset("test_link_non_web_scheme.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose inline data reference declares its own encoding" do
      let(:content) { File.read(Decidim::Dev.asset("test_data_uri_declared_encoding.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose inline data reference has a fragment" do
      let(:content) { File.read(Decidim::Dev.asset("test_data_uri_fragment.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose inline data references declare the parameters of the MIME type in different positions" do
      let(:content) { File.read(Decidim::Dev.asset("test_data_uri_parameters.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG reaching the maximum depth of the nested inline data references" do
      let(:content) { File.read(Decidim::Dev.asset("test_data_uri_max_depth.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose animation assigns a presentation attribute referencing the document" do
      let(:content) { File.read(Decidim::Dev.asset("test_animation_presentation_reference.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose animation list of attribute names references elements of the document" do
      let(:content) { File.read(Decidim::Dev.asset("test_animation_attribute_names_list.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose presentation attributes reference elements of the document" do
      let(:content) { File.read(Decidim::Dev.asset("test_presentation_attribute_references.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose reference elements are resolved against the document itself" do
      let(:content) { File.read(Decidim::Dev.asset("test_reference_elements_resolved_in_document.svg")) }

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

    context "with an SVG whose animation assigns a single value containing the parameters of the MIME type of a data reference" do
      let(:content) { File.read(Decidim::Dev.asset("test_animation_data_uri_parameter.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose animation target and values use a percent encoded fragment" do
      let(:content) { File.read(Decidim::Dev.asset("test_animation_percent_encoded_fragment.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose style sheet references only elements of the document" do
      let(:content) { File.read(Decidim::Dev.asset("test_css_references.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose image function and color profile are resolved against the document itself" do
      let(:content) { File.read(Decidim::Dev.asset("test_relative_image_function.svg")) }

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG whose style sheet ends with an unterminated comment with multibyte characters" do
      let(:content) { File.read(Decidim::Dev.asset("test_css_unclosed_comment.svg")) }

      it "returns :valid without looping" do
        expect(Timeout.timeout(5) { validation }).to eq(:valid)
      end
    end

    context "with an SVG whose base is relative to the document itself" do
      let(:content) { File.read(Decidim::Dev.asset("test_relative_base.svg")) }

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
        malicious_svg_animation_fill.svg
        malicious_svg_animation_color_profile.svg
        malicious_svg_animation_attribute_names.svg
        malicious_svg_animation_attribute_names_list.svg
        malicious_svg_animation_attribute_names_event_handler.svg
        malicious_svg_animation_data_uri.svg
        malicious_svg_animation_data_uri_parameter.svg
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
        malicious_svg_css_image_function.svg
        malicious_svg_mask_attribute.svg
        malicious_svg_cursor_attribute.svg
        malicious_svg_fill_external_reference.svg
        malicious_svg_stroke_external_reference.svg
        malicious_svg_clip_path_external_reference.svg
        malicious_svg_filter_external_reference.svg
        malicious_svg_marker_external_reference.svg
        malicious_svg_marker_start_external_reference.svg
        malicious_svg_color_profile_external_reference.svg
        malicious_svg_stylesheet_pi.svg
        malicious_svg_entity.svg
        malicious_svg_entity_parameter.svg
        malicious_svg_data_uri_nested.svg
        malicious_svg_data_uri_parameter.svg
        malicious_svg_data_uri_leading_space.svg
        malicious_svg_data_uri_deep_nested.svg
        malicious_svg_data_uri_declared_encoding.svg
        malicious_svg_data_uri_fragment.svg
        malicious_svg_data_uri_base64_parameter_lookalike.svg
        malicious_svg_data_uri_base64_not_last_parameter.svg
        malicious_svg_data_uri_malformed_base64.svg
        malicious_svg_data_uri_malformed_document.svg
        malicious_svg_data_uri_max_depth_exceeded.svg
        malicious_svg_external_image.svg
        malicious_svg_external_use.svg
        malicious_svg_external_feimage.svg
        malicious_svg_cursor.svg
        malicious_svg_gradient_external_reference.svg
        malicious_svg_pattern_external_reference.svg
        malicious_svg_filter_element_external_reference.svg
        malicious_svg_text_path_external_reference.svg
        malicious_svg_mpath_external_reference.svg
        malicious_svg_tref_external_reference.svg
        malicious_svg_alt_glyph_external_reference.svg
        malicious_svg_font_face_uri_external_reference.svg
        malicious_svg_color_profile_element_external_reference.svg
        malicious_svg_animate_color_external_reference.svg
        malicious_svg_animation_gradient_reference.svg
        malicious_svg_backslash_reference.svg
        malicious_svg_protocol_relative_reference.svg
        malicious_svg_base.svg
        malicious_svg_base_child_element.svg
        malicious_svg_base_protocol_relative.svg
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

    context "with contents larger than the maximum size" do
      let(:content) { "a" * (described_class::MAX_CONTENT_SIZE + 1) }

      it_behaves_like "an invalid SVG document"
    end

    context "with an XML nesting depth beyond the limit the parser enforces" do
      let(:content) do
        depth = 257
        content = %(<svg xmlns="http://www.w3.org/2000/svg">)
        content += %(#{("<g>" * depth)}<circle r="1"/>#{("</g>" * depth)}</svg>)
        content
      end

      it_behaves_like "an invalid SVG document"
    end

    context "with an element name longer than the limit the parser enforces" do
      let(:content) do
        name = "a" * 65_536
        %(<svg xmlns="http://www.w3.org/2000/svg"><#{name} width="1"></#{name}></svg>)
      end

      it_behaves_like "an invalid SVG document"
    end

    context "with an SVG with many elements and references, which stays under the limits" do
      let(:content) do
        references = %(<use href="#dot"/><image href="logo.png"/>) * 5000
        %(<svg xmlns="http://www.w3.org/2000/svg"><defs><circle id="dot" r="1"/></defs>#{references}</svg>)
      end

      it_behaves_like "a valid SVG document"
    end

    context "with an SVG with a long reference which is not an external one" do
      let(:content) do
        %(<svg xmlns="http://www.w3.org/2000/svg"><image href="#{"a" * 100_000}" width="1" height="1"/></svg>)
      end

      it_behaves_like "a valid SVG document"
    end
  end
end
