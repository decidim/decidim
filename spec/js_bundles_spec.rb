# frozen_string_literal: true

describe "Js bundle sanity" do
  shared_examples "a valid bundle" do
    it "is up to date" do
      previous_hash = bundle_hash

      expect(system(command, out: File::NULL, err: File::NULL)).to eq(true)

      new_hash = bundle_hash

      expect(previous_hash).to eq(new_hash),
                               "Please normalize the #{bundle_path} bundle with `#{command}` from the Decidim root folder"
    end
  end

  let(:command) { "npm run build:prod" }

  describe "javascript admin bundle" do
    let(:bundle_path) { "decidim-admin/app/assets/javascripts/decidim/admin/bundle.js" }

    it_behaves_like "a valid bundle"
  end

  describe "styles bundle" do
    let(:bundle_path) { "decidim-admin/app/assets/stylesheets/decidim/admin/bundle.scss" }

    it_behaves_like "a valid bundle"
  end

  describe "javascript comments bundle" do
    let(:bundle_path) { "decidim-comments/app/assets/javascripts/decidim/comments/bundle.js" }

    it_behaves_like "a valid bundle"
  end

  def bundle_hash
    Digest::MD5.file(bundle_path).hexdigest
  end
end
