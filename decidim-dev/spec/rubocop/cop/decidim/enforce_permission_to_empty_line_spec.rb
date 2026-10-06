# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "decidim/dev/rubocop/cop/decidim/enforce_permission_to_empty_line"

RSpec.describe RuboCop::Cop::Decidim::EnforcePermissionToEmptyLine, :config, type: :cop do
  it "registers an offense and adds an empty line when code follows enforce_permission_to" do
    expect_offense(<<~RUBY)
      def edit
        enforce_permission_to :update, :resource
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
        @resource = Resource.find(params[:id])
      end
    RUBY

    expect_correction(<<~RUBY)
      def edit
        enforce_permission_to :update, :resource

        @resource = Resource.find(params[:id])
      end
    RUBY
  end

  it "registers an offense when enforce_permission_to uses parentheses" do
    expect_offense(<<~RUBY)
      def edit
        enforce_permission_to(:update, :resource)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
        @resource = Resource.find(params[:id])
      end
    RUBY

    expect_correction(<<~RUBY)
      def edit
        enforce_permission_to(:update, :resource)

        @resource = Resource.find(params[:id])
      end
    RUBY
  end

  it "registers an offense for a multiline enforce_permission_to call" do
    expect_offense(<<~RUBY)
      def edit
        enforce_permission_to :update,
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
                              :resource
        @resource = Resource.find(params[:id])
      end
    RUBY
  end

  it "registers an offense inside a before_action block" do
    expect_offense(<<~RUBY)
      before_action do
        enforce_permission_to :update, :resource
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      before_action do
        enforce_permission_to :update, :resource

        do_something_else
      end
    RUBY
  end

  it "registers an offense inside an explicit begin block" do
    expect_offense(<<~RUBY)
      def edit
        begin
          enforce_permission_to :update, :resource
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def edit
        begin
          enforce_permission_to :update, :resource

          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers several offenses in the same method" do
    expect_offense(<<~RUBY)
      def edit
        enforce_permission_to :update, :resource
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
        @resource = Resource.find(params[:id])
        enforce_permission_to :read, :resource
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `enforce_permission_to`.
        @resource.publish
      end
    RUBY

    expect_correction(<<~RUBY)
      def edit
        enforce_permission_to :update, :resource

        @resource = Resource.find(params[:id])
        enforce_permission_to :read, :resource

        @resource.publish
      end
    RUBY
  end

  it "does not register an offense when the empty line is already present" do
    expect_no_offenses(<<~RUBY)
      def edit
        enforce_permission_to :update, :resource

        @resource = Resource.find(params[:id])
      end
    RUBY
  end

  it "does not register an offense when enforce_permission_to is the only statement" do
    expect_no_offenses(<<~RUBY)
      def edit
        enforce_permission_to :update, :resource
      end
    RUBY
  end

  it "does not register an offense when enforce_permission_to is the last statement" do
    expect_no_offenses(<<~RUBY)
      def edit
        @resource = Resource.find(params[:id])
        enforce_permission_to :update, :resource
      end
    RUBY
  end

  it "does not register an offense when enforce_permission_to is the last statement of an explicit begin block" do
    expect_no_offenses(<<~RUBY)
      def edit
        begin
          @resource = Resource.find(params[:id])
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not register an offense when enforce_permission_to is the only statement of an explicit begin block" do
    expect_no_offenses(<<~RUBY)
      def edit
        begin
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not register an offense for unrelated method calls" do
    expect_no_offenses(<<~RUBY)
      def edit
        do_something
        @resource = Resource.find(params[:id])
      end
    RUBY
  end
end
