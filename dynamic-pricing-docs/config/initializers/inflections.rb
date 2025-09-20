# Be sure to restart your server when you modify this file.
=begin
What this file is:
- This is a Rails initializer. Initializers are evaluated once at application boot (in all environments),
  similar in spirit to ASP.NET Core's Program.cs/Startup.cs where you configure framework behavior.
- Because initializers run at boot, Rails won't usually reload changes made here in development.
  Restart your server (or console) after edits to see them take effect.

What "inflections" are:
- ActiveSupport::Inflector is Rails' utility for transforming words:
  - pluralize/singularize: "person" => "people", "people" => "person"
  - camelize/underscore:   "user_account" => "UserAccount", "RESTfulAPI" => "restful_api"
  - classify/tableize:     "user_accounts" => "UserAccount", "UserAccount" => "user_accounts"
- Rails relies on these transformations pervasively:
  - Mapping model names to database table names (e.g., User -> users).
  - Inferring controller names, helper modules, mailer names, etc.
  - Autoloading constants from file paths (Zeitwerk uses underscore/camelize).
- If your domain has special nouns (irregular plurals, uncountables) or acronyms (API, REST, JSON),
  define them here so Rails' naming conventions align with your intent.

Locale-specific rules:
- The example uses :en (English). You can define per-locale rules if your app supports multiple locales.

Priority and safety:
- Rules you add are appended and take precedence over built-in defaults.
- The examples below are commented out. Uncomment (or add your own) inside the block to activate them.
- Changing inflections can affect autoloading and table/model mapping—make sure file names and constant
  names remain consistent (e.g., an acronym "API" means "APIClient".underscore => "api_client", so the
  file should be named api_client.rb).

How to experiment quickly (in a Rails console):
- "ox".pluralize
- "people".singularize
- "api_client".camelize
- "RESTfulAPI".underscore

Ruby/Regex notes (helpful if you're coming from C#/TS):
- Regex literals use /.../ with flags like /i for case-insensitive (similar to JS /.../i).
- Replacement backreferences use "\\1" in Ruby strings (double backslash). In Ruby, "\1" inside a
  double-quoted string is interpreted as an octal escape, so you need "\\1" to mean a literal \1.
- %w( a b c ) is Ruby's shorthand for an array of strings: ["a", "b", "c"].
=end

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|       # Open the inflection DSL for the :en (English) locale.
#   inflect.plural /^(ox)$/i, "\\1en"                          # "ox" => "oxen". Regex captures "ox" and replaces with "\1en".
#                                                              # Note the case-insensitive flag /i and double backslash in "\\1".
#   inflect.singular /^(ox)en/i, "\\1"                         # "oxen" => "ox". Inverse of the rule above.
#   inflect.irregular "person", "people"                       # Irregular noun mapping (both singular and plural provided).
#                                                              # Affects both singularize/pluralize and tableize/classify.
#   inflect.uncountable %w( fish sheep )                       # Words that have no plural form ("fish" remains "fish").
# end                                                          # End of the inflection block.

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|       # You can define acronyms to preserve capitalization in camelize.
#   inflect.acronym "RESTful"                                  # Treat "RESTful" as a single unit. Example:
#                                                              # "RESTfulAPI".underscore => "restful_api"
#                                                              # "restful_api".camelize => "RESTfulAPI"
#                                                              # This helps constant/file name alignment with Zeitwerk autoloading.
# end