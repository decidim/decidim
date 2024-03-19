# frozen_string_literal: true

require "spec_helper"

# Specs in this file have access to a helper object that includes
# the NewslettersHelper. For example:
#
module Decidim
  describe NewslettersHelper do
    let(:user) { create(:user, name: "Jane Doe", organization:) }
    let(:organization) { create(:organization, host: "localhost") }
    let(:newsletter) { create(:newsletter) }
    let(:text) do
      %{(<p>Hello, %{name}</p>
<a href="https://meta.decidim.org">Link</a>
<img src="/rails/active_storage/blobs/redirect/12345.JPG" alt="image" />
<a href="https://meta.decidim.org/">Link</a>
<img src="/rails/active_storage/blobs/redirect/56789.JPG" alt="second image" />)}
    end

    describe "#parse_interpolations" do
      subject { helper.parse_interpolations(text, user, newsletter.id) }

      it "replaces %{name} with user name" do
        expect(subject).to include("Hello, Jane Doe")
      end

      it "replaces links with utm codes" do
        expect(subject).to include("https://meta.decidim.org?utm_source=#{organization.host}&utm_campaign=newsletter_#{newsletter.id}")
        expect(subject).to include("https://meta.decidim.org/?utm_source=#{organization.host}&utm_campaign=newsletter_#{newsletter.id}")
      end

      it "transforms image URLs with the host" do
        expect(subject).to include('<img src="http://localhost/rails/active_storage/blobs/redirect/12345.JPG"')
        expect(subject).to include('<img src="http://localhost/rails/active_storage/blobs/redirect/56789.JPG"')
      end

      context "when track_newsletter_links is false" do
        before do
          allow(Decidim.config).to receive(:track_newsletter_links).and_return(false)
        end

        it "does not replace links with utm codes" do
          expect(subject).to include('<a href="https://meta.decidim.org">Link</a>')
          expect(subject).to include('<a href="https://meta.decidim.org/">Link</a>')
          expect(subject).not_to include("?utm_source=#{organization.host}&utm_campaign=newsletter_#{newsletter.id}")
        end
      end

      context "when the user is not present" do
        subject { helper.parse_interpolations(text) }

        it { is_expected.to include("<p>Hello, </p>") }

        it "does not replace links with utm codes" do
          expect(subject).to include('<a href="https://meta.decidim.org">Link</a>')
          expect(subject).to include('<a href="https://meta.decidim.org/">Link</a>')
          expect(subject).not_to include("?utm_source=#{organization.host}&utm_campaign=newsletter_#{newsletter.id}")
        end
      end
    end

    describe "#custom_url_for_mail_root" do
      let(:organization) { create(:organization) }

      describe "when newsletter present" do
        subject { helper.custom_url_for_mail_root(organization, newsletter.id) }

        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq(decidim.root_url(host: organization.host, port: Capybara.server_port) + utm_codes(organization.host, newsletter.id.to_s)) }
      end

      describe "when newsletter not present" do
        subject { helper.custom_url_for_mail_root(organization) }

        it { is_expected.to eq(decidim.root_url(host: organization.host, port: Capybara.server_port)) }
      end
    end

    describe "#utm_codes" do
      subject { helper.send(:utm_codes, organization.host, newsletter.id) }

      it "returns the utm codes" do
        expect(subject).to eq("?utm_source=#{organization.host}&utm_campaign=#{newsletter.id}")
      end
    end

    describe "#interpret_name" do
      subject { helper.send(:interpret_name, text, user) }

      it "replaces '%{name}' with user name" do
        expect(subject).to include("Hello, Jane Doe")
      end

      context "when user is not present" do
        subject { helper.send(:interpret_name, text, nil) }

        it { is_expected.to include("<p>Hello, </p>") }
      end
    end

    describe "#transform_image_urls" do
      subject { helper.send(:transform_image_urls, text, organization.host) }

      it "transforms image URLs with the host" do
        expect(subject).to include('<img src="http://localhost/rails/active_storage/blobs/redirect/12345.JPG"')
        expect(subject).to include('<img src="http://localhost/rails/active_storage/blobs/redirect/56789.JPG"')
      end

      context "when host is not present" do
        subject { helper.send(:transform_image_urls, text, nil) }

        it "returns the full content" do
          expect(subject).to eq text
        end
      end
    end
  end
end
