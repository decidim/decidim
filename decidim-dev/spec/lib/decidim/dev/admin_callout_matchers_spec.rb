# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_admin_callout matcher" do
  describe "anti-pattern detection" do
    context "with single-word anti-patterns" do
      it "fails for 'successfully'" do
        expect do
          matcher = have_admin_callout("successfully")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'problem'" do
        expect do
          matcher = have_admin_callout("problem")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'error'" do
        expect do
          matcher = have_admin_callout("error")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'warning'" do
        expect do
          matcher = have_admin_callout("warning")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'Done' (capitalized)" do
        expect do
          matcher = have_admin_callout("Done")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'OK'" do
        expect do
          matcher = have_admin_callout("OK")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'created'" do
        expect do
          matcher = have_admin_callout("created")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'updated'" do
        expect do
          matcher = have_admin_callout("updated")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'deleted'" do
        expect do
          matcher = have_admin_callout("deleted")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'published'" do
        expect do
          matcher = have_admin_callout("published")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'unpublished'" do
        expect do
          matcher = have_admin_callout("unpublished")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end
    end

    context "with very short strings" do
      it "fails for 5-character strings like 'Error'" do
        expect do
          matcher = have_admin_callout("Error")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for strings with punctuation like 'Error!'" do
        expect do
          matcher = have_admin_callout("Error!")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for short multi-word strings like 'Error now'" do
        expect do
          matcher = have_admin_callout("Error now")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end

      it "fails for 'Bad data'" do
        expect do
          matcher = have_admin_callout("Bad data")
          matcher.matches?(Object.new)
        end.to raise_error(/Anti-pattern detected/)
      end
    end

    context "edge cases" do
      it "does not fail for nil" do
        expect do
          matcher = have_admin_callout(nil)
          matcher.matches?(Object.new)
        end.not_to raise_error
      end

      it "does not fail for symbols" do
        expect do
          matcher = have_admin_callout(:some_symbol)
          matcher.matches?(Object.new)
        end.not_to raise_error
      end

      it "provides helpful error messages with grep command" do
        expect do
          matcher = have_admin_callout("successfully")
          matcher.matches?(Object.new)
        end.to raise_error(/grep.*have_admin_callout.*successfully/)
      end

      it "mentions minimum length threshold in error message" do
        expect do
          matcher = have_admin_callout("Bad data")
          matcher.matches?(Object.new)
        end.to raise_error(/12.*characters/)
      end

      it "provides example replacements in error message" do
        expect do
          matcher = have_admin_callout("successfully")
          matcher.matches?(Object.new)
        end.to raise_error(/Meeting successfully published/)
      end
    end
  end
end
