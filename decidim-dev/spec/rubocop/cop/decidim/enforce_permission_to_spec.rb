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

  it "registers an offense for actions defined after visibility is switched back to public" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def index
        ^^^^^^^^^ Action `index` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resources = Resource.all
        end

        private

        def resource
          @resource ||= Resource.find(params[:id])
        end

        public

        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for methods following a protected section reopened after private" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private

        def resource
          @resource ||= Resource.find(params[:id])
        end

        protected

        def protected_resource
          @resource ||= Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for an action defined with the public keyword after a private section" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private

        def resource
          @resource ||= Resource.find(params[:id])
        end

        public

        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense for a method made private with the private keyword and def argument" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private def resource
          @resource ||= Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for a public action after a method made private with the private keyword and def argument" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private def resource
          @resource ||= Resource.find(params[:id])
        end

        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for a method made public with the public keyword and a symbol argument" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private

        def publish
        ^^^^^^^^^^^ Action `publish` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource.publish
        end

        public :publish
      end
    RUBY
  end

  it "registers an offense for a method made public with the public keyword and an array argument" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private

        def publish
        ^^^^^^^^^^^ Action `publish` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource.publish
        end

        public [:publish]
      end
    RUBY
  end

  it "does not register an offense for a method made private with the private keyword and a symbol argument" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def resource
          @resource ||= Resource.find(params[:id])
        end

        private :resource
      end
    RUBY
  end

  it "does not register an offense for a method made private with several symbol arguments" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def resource
          @resource ||= Resource.find(params[:id])
        end

        def collection
          @collection ||= Resource.all
        end

        private :resource, :collection
      end
    RUBY
  end

  it "registers an offense for a method made public after being defined as private with a def argument" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        private def publish
                ^^^^^^^^^^^ Action `publish` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource.publish
        end

        public :publish
      end
    RUBY
  end

  it "registers an offense when a later public def redefines a method made private with a symbol" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def publish
        end

        private :publish

        public def publish
               ^^^^^^^^^^^ Action `publish` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource.publish
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

  it "registers an offense for public methods starting with set_" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def set_resource
        ^^^^^^^^^^^^^^^^ Action `set_resource` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for public methods starting with load_" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def load_resource
        ^^^^^^^^^^^^^^^^^ Action `load_resource` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for public methods starting with find_" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def find_resource
        ^^^^^^^^^^^^^^^^^ Action `find_resource` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense for public methods starting with build_" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def build_resource
        ^^^^^^^^^^^^^^^^^^ Action `build_resource` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.new
        end
      end
    RUBY
  end

  it "registers an offense for public methods starting with _" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def _internal_action
        ^^^^^^^^^^^^^^^^^^^^ Action `_internal_action` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          do_something
        end
      end
    RUBY
  end

  it "registers an offense for custom actions like publish without authorization" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def publish
        ^^^^^^^^^^^ Action `publish` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource.publish
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

  it "exempts only the actions covered by a before_action with only" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :authorize_access, only: [:edit]

        def index
        ^^^^^^^^^ Action `index` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resources = Resource.all
        end

        def edit
          @resource = Resource.find(params[:id])
        end

        private

        def authorize_access
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "exempts actions covered by a before_action with a single symbol only" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :authorize_access, only: :edit

        def edit
          @resource = Resource.find(params[:id])
        end

        private

        def authorize_access
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "exempts all the actions not covered by a before_action with except" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :authorize_access, except: [:index]

        def index
        ^^^^^^^^^ Action `index` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resources = Resource.all
        end

        def edit
          @resource = Resource.find(params[:id])
        end

        private

        def authorize_access
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not exempt an action excluded by except when only is also given" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :authorize_access, only: [:edit], except: [:edit]

        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end

        private

        def authorize_access
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "exempts only the actions covered by both only and except" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :authorize_access, only: [:edit, :update], except: [:update]

        def edit
          @resource = Resource.find(params[:id])
        end

        def update
        ^^^^^^^^^^ Action `update` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end

        private

        def authorize_access
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not exempt actions covered by a non-auth before_action with only" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action :set_breadcrumb, only: [:edit]

        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resource = Resource.find(params[:id])
        end

        private

        def set_breadcrumb
          breadcrumb_items << { label: "Edit" }
        end
      end
    RUBY
  end

  it "exempts only the actions covered by a before_action block with only" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        before_action only: [:edit] do
          enforce_permission_to :update, :resource
        end

        def index
        ^^^^^^^^^ Action `index` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          @resources = Resource.all
        end

        def edit
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "does not register an offense when action calls an enforce_permission_to wrapper method" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
          enforce_permission_to_update_resource
          @resource = Resource.find(params[:id])
        end

        private

        def enforce_permission_to_update_resource
          enforce_permission_to :update, :resource
        end
      end
    RUBY
  end

  it "does not register an offense when action calls an action_authorized_to wrapper method" do
    expect_no_offenses(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
          action_authorized_to_edit_resource
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  it "registers an offense when action only calls a method containing permission" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          resource_permissions
          @resource = Resource.find(params[:id])
        end

        private

        def resource_permissions
          @resource.permissions
        end
      end
    RUBY
  end

  it "registers an offense when action only calls a method containing authorize" do
    expect_offense(<<~RUBY)
      class Admin::ResourcesController < Admin::ApplicationController
        def edit
        ^^^^^^^^ Action `edit` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
          authorize_url
          @resource = Resource.find(params[:id])
        end
      end
    RUBY
  end

  describe "lifecycle and helper methods" do
    it "does not register an offense for a method referenced by before_action" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          before_action :set_locale

          def set_locale
            I18n.locale = :en
          end
        end
      RUBY
    end

    it "does not register an offense for a method referenced by prepend_before_action" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          prepend_before_action :set_locale

          def set_locale
            I18n.locale = :en
          end
        end
      RUBY
    end

    it "does not register an offense for a method referenced by skip_before_action" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          skip_before_action :set_locale

          def set_locale
            I18n.locale = :en
          end
        end
      RUBY
    end

    it "does not register an offense for a method referenced by around_action" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          around_action :use_time_zone

          def use_time_zone(&block)
            Time.use_zone("UTC", &block)
          end
        end
      RUBY
    end

    it "does not register an offense for a method referenced by after_action" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          after_action :set_vary_header

          def set_vary_header
            response.headers["Vary"] = "Accept"
          end
        end
      RUBY
    end

    it "does not register an offense for a method referenced by helper_method" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          helper_method :current_locale

          def current_locale
            I18n.locale
          end
        end
      RUBY
    end

    it "does not register an offense for a rescue_from handler registered with with:" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          rescue_from ActionController::ParameterMissing, with: :handle_error

          def handle_error
            redirect_to root_path
          end
        end
      RUBY
    end

    it "does not register an offense for a method called by a lifecycle method" do
      expect_no_offenses(<<~RUBY)
        class Admin::ResourcesController < Admin::ApplicationController
          after_action :append_headers

          def append_headers
            response.headers["Content-Security-Policy"] = content_security_policy.output_policy
          end

          def content_security_policy
            @content_security_policy ||= Decidim::ContentSecurityPolicy.new(current_organization)
          end
        end
      RUBY
    end

    it "does not register an offense for a lifecycle method defined in a nested module" do
      expect_no_offenses(<<~RUBY)
        module Admin
          module GetOrganization
            def self.enhance_controller(instance_or_module)
              instance_or_module.class_eval do
                helper_method :current_organization
              end
            end

            module InstanceMethods
              def current_organization
                request.env["decidim.current_organization"]
              end
            end
          end
        end
      RUBY
    end
  end

  describe "authorized base classes" do
    context "when the controller inherits from an authorized base class" do
      let(:cop_config) do
        {
          "AuthorizedBaseClasses" => ["Decidim::Components::BaseController"],
          "AuthorizedBaseActions" => %w(index show home)
        }
      end

      it "does not register offenses for inherited read-style actions" do
        expect_no_offenses(<<~RUBY)
          class Decidim::Blogs::PostsController < Decidim::Components::BaseController
            def index; end

            def show; end

            def home; end
          end
        RUBY
      end

      it "does not register offenses for read-style actions inherited through another class" do
        expect_no_offenses(<<~RUBY)
          class Decidim::Accountability::ApplicationController < Decidim::Components::BaseController
          end

          class Decidim::Accountability::ResultsController < Decidim::Accountability::ApplicationController
            def show; end
          end
        RUBY
      end

      it "registers an offense for a mutating action" do
        expect_offense(<<~RUBY)
          class Decidim::Blogs::PostsController < Decidim::Components::BaseController
            def create
            ^^^^^^^^^^ Action `create` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
              @post = Post.create(post_params)
            end
          end
        RUBY
      end

      it "registers an offense for a custom action" do
        expect_offense(<<~RUBY)
          class Decidim::Blogs::PostsController < Decidim::Components::BaseController
            def publish
            ^^^^^^^^^^^ Action `publish` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
              @post.publish
            end
          end
        RUBY
      end
    end

    context "when the controller does not inherit from an authorized base class" do
      let(:cop_config) do
        {
          "AuthorizedBaseClasses" => ["Decidim::Components::BaseController"],
          "AuthorizedBaseActions" => %w(index show home)
        }
      end

      it "registers an offense for a read-style action" do
        expect_offense(<<~RUBY)
          class Admin::ResourcesController < Admin::ApplicationController
            def index
            ^^^^^^^^^ Action `index` is missing an authorization check. Add `enforce_permission_to` or `action_authorized_to` at the start of the action, or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere.
              @resources = Resource.all
            end
          end
        RUBY
      end
    end
  end
end
