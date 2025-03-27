# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs
  describe SchemaOrgBlogPostingPostSerializer do
    subject do
      described_class.new(post)
    end

    let!(:post) { create(:post, component:, author:) }
    let(:organization) { create(:organization) }
    let(:component) { create(:post_component, participatory_space:) }
    let(:participatory_space) { create(:participatory_process, :with_steps, skip_injection: false, organization:) }
    let(:author) { organization }

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the @context" do
        expect(serialized[:@context]).to eq("https://schema.org")
      end

      it "serializes the @type" do
        expect(serialized[:@type]).to eq("BlogPosting")
      end

      it "serializes the headline" do
        expect(serialized).to include(headline: decidim_escape_translated(post.title))
      end

      describe "datePublished" do
        context "when it is not published" do
          before do
            post.update!(published_at: 1.week.from_now)
          end

          it "does not has the attribute" do
            expect(serialized).not_to include(:datePublished)
          end
        end

        context "when it is published" do
          let(:published_at) { Time.current }

          before do
            post.update!(published_at:)
          end

          it "has the attribute" do
            expect(serialized).to include(datePublished: published_at.iso8601)
          end
        end
      end

      describe "authors" do
        context "with official author" do
          let(:author) { organization }

          it "serializes the author" do
            expect(serialized[:author][:@type]).to eq("Organization")
            expect(serialized[:author][:name]).to eq(translated_attribute(post.author.name))
            expect(serialized[:author][:url]).to eq("http://#{organization.host}:#{Capybara.server_port}/")
          end
        end

        context "with participant author" do
          let(:author) { create(:user, organization:) }

          it "serializes the author" do
            expect(serialized[:author][:@type]).to eq("Person")
            expect(serialized[:author][:name]).to eq(post.author.name)
            expect(serialized[:author][:url]).to eq("http://#{organization.host}:#{Capybara.server_port}/profiles/#{post.author.nickname}")
          end

          context "when author is deleted" do
            let(:author) { create(:user, :deleted, organization:) }

            it "serializes the author" do
              expect(serialized[:author][:@type]).to eq("Person")
              expect(serialized[:author][:name]).to eq(post.author.name)
              expect(serialized[:author][:url]).to eq("")
            end
          end
        end
      end

      describe "images" do
        context "without images" do
          it "does not has the attribute" do
            expect(serialized).not_to include(:image)
          end
        end

        context "with one image" do
          let!(:attachment) { create(:attachment, :with_image, attached_to: post, file: attachment_file) }
          let!(:attachment_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }

          it "serializes the image" do
            expect(serialized[:image]).to include(attachment.thumbnail_url)
          end
        end

        context "with multiple images" do
          let!(:attachment1) { create(:attachment, :with_image, attached_to: post, file: attachment1_file) }
          let!(:attachment1_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
          let!(:attachment2) { create(:attachment, :with_image, attached_to: post, file: attachment2_file) }
          let!(:attachment2_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }

          it "serializes the images" do
            expect(serialized[:image]).to include(attachment1.thumbnail_url)
            expect(serialized[:image]).to include(attachment2.thumbnail_url)
          end
        end
      end
    end
  end
end
