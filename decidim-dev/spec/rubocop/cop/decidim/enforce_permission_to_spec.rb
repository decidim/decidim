# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "decidim/dev/rubocop/cop/decidim/enforce_permission_to"

RSpec.describe RuboCop::Cop::Decidim::EnforcePermissionTo, :config, type: :cop do
  it "registers an offense for an action without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for update without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def update
        ^^^^^^^^^^ Action `update` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
          @resource.update(resource_params)
        end
      end
    RUBY
  end

  it "registers an offense for index without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def index
        ^^^^^^^^^ Action `index` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resources = Resource.all
        end
      end
    RUBY
  end

  it "registers an offense for show without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def show
        ^^^^^^^^ Action `show` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for new without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def new
        ^^^^^^^ Action `new` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.new
        end
      end
    RUBY
  end

  it "registers an offense for create without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def create
        ^^^^^^^^^^ Action `create` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.create(resource_params)
        end
      end
    RUBY
  end

  it "registers an offense for destroy without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def destroy
        ^^^^^^^^^^^ Action `destroy` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
          @resource.destroy
        end
      end
    RUBY
  end

  it "registers offenses for multiple actions without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end

        def update
        ^^^^^^^^^^ Action `update` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
          @resource.update(resource_params)
        end
      end
    RUBY
  end

  it "does not register an offense when action has enforce_permission_to" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
          enforce_permission_to :update, :resource, resource: @resource
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense when action has enforce_permission_to with parentheses" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
          enforce_permission_to(:update, :resource, resource: @resource)
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense when action has action_authorized_to" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
          action_authorized_to :update, resource: @resource
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for private methods" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private

        def resource
          @resource ||= Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for protected methods" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        protected

        def resource
          @resource ||= Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense when before_action handles authorization with permission keyword" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :enforce_resource_permissions

        def edit
          @resource = Resource.find(params[:id])
        end

        private

        def enforce_resource_permissions
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not register an offense when before_action handles authorization with authorize keyword" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :authorize_resource

        def edit
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense when before_action handles authorization with enforce keyword" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :ensure_permissions

        def edit
          @resource = Resource.find(params[:id])
        end

        private

        def ensure_permissions
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not register an offense when before_action has a block with enforce_permission_to" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action do
          enforce_permission_to :update, :resource
        end

        def edit
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for methods starting with set_" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def set_resource
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for methods starting with load_" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def load_resource
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for methods starting with find_" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def find_resource
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for methods starting with build_" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def build_resource
          @resource = Resource.new
        end
      end
    RUBY
  end

  it "does not register an offense for methods starting with _" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def _internal_action
          do_something
        end
      end
    RUBY
  end

  it "does not register an offense for a controller with no actions" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        helper_method :resource

        private

        def resource
          @resource ||= Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense when before_action uses a non-auth symbol alongside an auth one" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :set_breadcrumb
        before_action :authorize_access

        def edit
          @resource = Resource.find(params[:id])
        end

        private

        def set_breadcrumb
          breadcrumb_items << { label: "Edit" }
        end

        def authorize_access
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end
end
