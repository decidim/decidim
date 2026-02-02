# App directories

As decidim is a gem for Ruby on Rails you may find the usual rails directories: controllers, models, etc. but we also have other kind of directories.

## Standard Rails

| Directory    | Description                      | Technology             |
|--------------|----------------------------------|------------------------|
| controllers/ | HTTP request handlers            | Rails ActionController |
| models/      | ActiveRecord models and entities | Rails ActiveRecord     |
| views/       | ERB templates for rendering      | Rails ERB              |
| helpers/     | View helper methods              | Rails ActionView       |
| mailers/     | Email sending classes            | Rails ActionMailer     |
| jobs/        | Background job classes           | Rails ActiveJob        |

## Beyond Standard Rails

| Directory    | Description                                                 | Technology                                                        |
|--------------|-------------------------------------------------------------|-------------------------------------------------------------------|
| commands/    | Business logic encapsulating use cases (Command Pattern)    | Custom Decidim base class (inspired by Rectify gem).              |
| forms/       | Form objects for data validation and transformation         | Custom Form base class with Decidim::Attributes                   |
| cells/       | Reusable view components                                    | Trailblazer::Cells gem                                            |
| events/      | Activity logging, notifications, event triggering           | Custom Event classes (SimpleEvent, NotificationEvent, EmailEvent) |
| permissions/ | Authorization and permission checking logic                 | Custom Decidim permission system                                  |
| queries/     | Database query objects for complex queries                  | Custom Query base class                                           |
| presenters/  | Decorator classes for view-specific formatting              | SimpleDelegator-based                                             |
| services/    | Stateless utility and business service classes              | Plain Ruby classes                                                |
| validators/  | Custom validation classes                                   | Rails Custom Validators                                           |
| serializers/ | JSON/XML serialization for API responses                    | Custom serializers                                                |
| uploaders/   | File upload handling                                        | Custom validations for ActiveStorage                              |
| constraints/ | Rails routing constraints                                   | Custom constraint classes                                         |
| resolvers/   | GraphQL data resolution                                     | Custom resolver classes                                           |
| scrubbers/   | HTML content sanitization                                   | Rails::HTML::Scrubber                                             |
| packs/       | JavaScript/CSS entry points and assets                      | Shakapacker                                                       |
| assets/      | Static assets (some modules)                                | Asset pipeline                                                    |

## Key Architectural Patterns

**IMPORTANT: You must follow the existing patterns.**

1. **Command Pattern**: Commands in `app/commands/` encapsulate single use cases and broadcast events
2. **Form Objects**: Forms in `app/forms/` handle validation separately from models
3. **Cells**: Component-based views using `Trailblazer::Cells` for reusable UI
4. **Query Objects**: Complex database queries isolated in `app/queries/`
5. **Events**: Events trigger notifications, logs, and side effects
6. **Permission System**: Scope-based authorization with action/subject model
7. **Content Block System**: Customizable page sections via manifests
