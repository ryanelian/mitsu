# ApplicationController is the base class for all controllers in this Rails application.
# - Rails controller hierarchy is similar to ASP.NET Core where you'd create a base controller inheriting from ControllerBase.
# - Here we inherit from ActionController::API (not ActionController::Base), which configures this app in "API-only" mode:
#   * Slimmer middleware stack (no view rendering pipeline, no cookies/sessions by default).
#   * Comparable to using ControllerBase with [ApiController] in ASP.NET Core rather than full MVC Controller.
# - In a typical Rails app, every other controller will subclass this one, allowing you to centralize cross-cutting concerns:
#   * before_action filters (like middleware but per-controller), common authentication, error handling (rescue_from), etc.
# - File path and class name:
#   * app/controllers/application_controller.rb defines the constant ApplicationController (CamelCase).
#   * Rails (via Zeitwerk autoloader) maps path -> constant automatically, like how TypeScript/ES modules map file paths to exports.
# - Ruby syntax notes (for C#/TS folks):
#   * `<` denotes inheritance (subclassing).
#   * No braces; Ruby uses `end` to close class/method definitions.
#   * Class names are constants; reopening a class (defining it again) merges changes (handy in dev with code reloading).
# - ActionController::API vs ActionController::Base:
#   * If you need cookies, server-side sessions, or view rendering, you'd switch to ActionController::Base or include specific modules.
#   * You can granularly add features by including modules (e.g., include ActionController::Cookies) rather than switching base class.
class ApplicationController < ActionController::API # Inherit API-focused controller behavior (no views/sessions by default).
  # This class is intentionally empty right now—behavior comes from the superclass.
  # Common things you might add here later (analogous to ASP.NET Core filters/middleware in a base controller):
  # - before_action :authenticate_user      # Run a method before each action to enforce auth.
  # - rescue_from SomeError, with: :handle  # Centralized error handling -> consistent API error responses.
  # - helper methods marked private/protected for shared parameter parsing/serialization.
  # - include modules/concerns for cross-cutting features (e.g., pagination helpers).
  #
  # Notes on request/response handling in API mode:
  # - Strong parameters live in ActionController::Parameters (think of it like a model binder with explicit whitelisting).
  # - Rendering is usually via render json: {...}, status: :ok (or head :no_content for empty bodies).
  # - Content negotiation uses MIME types; for respond_to-style behavior you can include ActionController::MimeResponds.
  #
  # Security defaults:
  # - CSRF protection and cookies are not enabled by default in API mode (like not using AntiForgery middleware).
  # - If you add cookies/sessions, reconsider CSRF or rely on token-based auth (e.g., Authorization: Bearer ...).
end # class ApplicationController