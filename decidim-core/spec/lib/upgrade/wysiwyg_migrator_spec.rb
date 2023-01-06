# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Upgrade::WysiwygMigrator do
    let(:migrator) { described_class.new(content) }

    let(:organization) { create(:organization) }
    let(:image) { create(:attachment, attached_to: organization) }

    let(:content) do
      <<~HTML.gsub(/\n\s*/, "")
        <h2>Title of the content</h2>
        <p>This is a test content for the migrator.</p>
        <p class="ql-indent-1">We should support indentation</p>
        <p class="ql-indent-5">We should support indentation at all levels.</p>
        <h3>Below we will show some lists</h3>
        <ul>
          <li>Item 1</li>
          <li class="ql-indent-3">Item 1.1.1.1</li>
          <li>Item 2</li>
          <li class="ql-indent-1">Item 2.1</li>
          <li class="ql-indent-1">Item 2.2</li>
          <li class="ql-indent-2">Item 2.2.1</li>
          <li class="ql-indent-2">Item 2.2.2</li>
          <li class="ql-indent-1">Item 2.3</li>
          <li class="ql-indent-1">Item 2.4</li>
        </ul>
        <p><br></p>
        <ol>
          <li>Item 1</li>
          <li class="ql-indent-3">Item 1.1.1.1</li>
          <li>Item 2</li>
          <li class="ql-indent-1">Item 2.1</li>
          <li class="ql-indent-1">Item 2.2</li>
          <li class="ql-indent-2">Item 2.2.1</li>
          <li class="ql-indent-2">Item 2.2.2</li>
          <li class="ql-indent-1">Item 2.3</li>
          <li class="ql-indent-1">Item 2.4</li>
        </ol>
        <ul>
          <li class="ql-indent-3">Item 1.1.1.1</li>
        </ul>
        <p>
          Paragraph content with an inline image.
          <img src="#{image.url}">
          And some text after that.
        </p>
        <p><img src="#{image.url}" alt="This image had an alternative text"></p>
        <iframe class="ql-video" frameborder="0" allowfullscreen="true" src="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0"></iframe>
        <div><span>Here we had some unrecognized node.</span></div>
        <blockquote>Blockquote element content <br>should be <strong>wrapped inside</strong> a paragraph.</blockquote>
        <p>Code segments such as... <code>{"foo": "bar"}</code> ...have been converted to code blocks.</p>
        <p>This is the end of the document.</p>
      HTML
    end
    let(:expected_content) do
      <<~HTML.gsub(/\n\s*/, "")
        <h2>Title of the content</h2>
        <p>This is a test content for the migrator.</p>
        <p class="editor-indent-1">We should support indentation</p>
        <p class="editor-indent-5">We should support indentation at all levels.</p>
        <h3>Below we will show some lists</h3>
        <ul>
          <li>
            <p>Item 1</p>
            <ul>
              <li>
                <p></p>
                <ul>
                  <li>
                    <p></p>
                    <ul>
                      <li><p>Item 1.1.1.1</p></li>
                    </ul>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
          <li>
            <p>Item 2</p>
            <ul>
              <li><p>Item 2.1</p></li>
              <li>
                <p>Item 2.2</p>
                <ul>
                  <li><p>Item 2.2.1</p></li>
                  <li><p>Item 2.2.2</p></li>
                </ul>
              </li>
              <li><p>Item 2.3</p></li>
              <li><p>Item 2.4</p></li>
            </ul>
          </li>
        </ul>
        <p><br></p>
        <ol>
          <li>
            <p>Item 1</p>
            <ol>
              <li>
                <p></p>
                <ol>
                  <li>
                    <p></p>
                    <ol>
                      <li><p>Item 1.1.1.1</p></li>
                    </ol>
                  </li>
                </ol>
              </li>
            </ol>
          </li>
          <li>
            <p>Item 2</p>
            <ol>
              <li><p>Item 2.1</p></li>
              <li>
                <p>Item 2.2</p>
                <ol>
                  <li><p>Item 2.2.1</p></li>
                  <li><p>Item 2.2.2</p></li>
                </ol>
              </li>
              <li><p>Item 2.3</p></li>
              <li><p>Item 2.4</p></li>
            </ol>
          </li>
        </ol>
        <ul>
          <li>
            <p></p>
            <ul>
              <li>
                <p></p>
                <ul>
                  <li>
                    <p></p>
                    <ul>
                      <li><p>Item 1.1.1.1</p></li>
                    </ul>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>
        <p>Paragraph content with an inline image.</p>
        <div class="editor-content-image" data-image="">
          <img src="#{image.url}" alt="">
        </div>
        <p>And some text after that.</p>
        <div class="editor-content-image" data-image="">
          <img src="#{image.url}" alt="This image had an alternative text">
        </div>
        <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0">
          <div>
            <iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc?showinfo=0" title="" frameborder="0" allowfullscreen="true"></iframe>
          </div>
        </div>
        <div><span>Here we had some unrecognized node.</span></div>
        <blockquote><p>Blockquote element content <br>should be <strong>wrapped inside</strong> a paragraph.</p></blockquote>
        <p>Code segments such as... </p>
        <pre>
          <code class="code-block">{"foo": "bar"}</code>
        </pre>
        <p> ...have been converted to code blocks.</p>
        <p>This is the end of the document.</p>
      HTML
    end

    shared_examples "HTML content migration" do
      subject { migrator.run }

      it "converts the content structure correctly" do
        expect(subject).to eq(expected_content)
      end

      context "when the content has already been converted" do
        let(:content) { expected_content }

        it "does not change the content" do
          expect(subject).to eq(expected_content)
        end
      end
    end

    describe "#run" do
      subject { migrator.run }

      it_behaves_like "HTML content migration"
    end

    describe ".convert" do
      subject { described_class.convert(content) }

      it_behaves_like "HTML content migration"
    end
  end
end
