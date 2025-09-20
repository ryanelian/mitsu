=begin
This file declares the URL -> controller/action mappings (routes) for a Rails app.
If you come from ASP.NET Core, think of this as the combined equivalent of:
- endpoint routing configuration inside UseEndpoints / MapControllers
- attribute routing on controllers (but centralized here by default)

Rails provides a small DSL (domain-specific language) for routes. It's evaluated
at boot and cached in production for performance.

Key Rails conventions referenced here:
- Controllers live in app/controllers and are named like PricingController.
- The 'index' action is a public instance method on that controller.
- The string 'pricing#index' means "call PricingController#index".
- By default, routes generate path helpers (e.g., pricing_path, pricing_url),
  similar to ASP.NET route name helpers, which you can call in views/controllers.
=end
Rails.application.routes.draw do  # Opens the routing DSL scope for this Rails app

  # Defines a single HTTP GET route:
  # - Path: /pricing (leading slash is standard; '/pricing' and 'pricing' behave the same)
  # - Controller#action: pricing#index => PricingController#index
  # - HTTP verb specificity: only responds to GET; POST/PUT/etc. to /pricing will 404
  # - Route helpers: generates pricing_path (relative) and pricing_url (absolute)
  # In ASP.NET Core terms, this is akin to endpoints.MapGet("/pricing", ...), where the handler
  # is a controller action discovered by name-convention instead of a lambda.
  get '/pricing', to: 'pricing#index'  # Map GET /pricing to PricingController#index

end  # Closes the routes.draw DSL block; all routes must be declared inside this block