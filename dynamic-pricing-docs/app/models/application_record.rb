# ApplicationRecord is the base model class for all Active Record models in a Rails app.
# If you're coming from C#/ASP.NET Core with EF Core: think of this as the common abstract
# DbContext-backed base entity class, except in Rails every model typically inherits from
# ActiveRecord::Base via this ApplicationRecord. This keeps app-specific configuration in one place.
# Rails generators (rails g model ...) will make new models inherit from ApplicationRecord by default.
#
# Key Rails/Ruby notes:
# - Ruby constants (CamelCase) define classes/modules. File name doesn't need to match exactly but
#   Rails' autoloading expects app/models/application_record.rb to define ApplicationRecord.
# - ActiveRecord::Base provides the ORM: persistence, querying, validations, callbacks, etc.
# - primary_abstract_class is a Rails 7+ convenience that marks the class as abstract and associates
#   it with the primary database connection. It's akin to "abstract class" in C#, but as a runtime flag.
# - No methods here means zero runtime overhead beyond inheritance; this file is a convention hook.

class ApplicationRecord < ActiveRecord::Base  # Inherit from the Rails ORM base; all models subclass this
  primary_abstract_class                      # Declare this as the abstract base for models (no table)
end                                           # End of class definition