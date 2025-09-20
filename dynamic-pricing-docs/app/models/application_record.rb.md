# Executive Summary
- File: app/models/application_record.rb
- TL;DR: Defines the application-wide base model class. It inherits from ActiveRecord::Base and is marked as an abstract “primary” model so real models inherit from it and don’t map to a table directly.

# Ruby Concepts
| Ruby Concept | What It Is | C#/TS Analogy |
| --- | --- | --- |
| Class definition | Declares a class and its inheritance chain | C#: class Foo : Bar; TS: class Foo extends Bar |
| Inheritance operator (<) | Indicates subclassing from another class | C#: : BaseClass; TS: extends BaseClass |
| Class body method call | Calling a class method without receiver inside the class body | C#: static method/attribute on the class; TS: static method call |

# Rails Concepts
| Rails Concept | What It Is | ASP.NET/React Analogy |
| --- | --- | --- |
| ActiveRecord::Base | ORM base providing persistence, validations, callbacks | EF Core’s tracked entity behavior (though EF uses POCOs; think BaseEntity helper) |
| ApplicationRecord | App-specific base for all models to centralize shared behavior | A BaseEntity class all entities inherit from |
| primary_abstract_class | Rails macro marking the class abstract and the primary connection owner | C#: abstract class; no direct “primary DB” equivalent |

# Code Anatomy
- class ApplicationRecord < ActiveRecord::Base: Base model all app models should inherit from; central place for shared model behavior.
- primary_abstract_class: Declares the class abstract (no table mapping) and designates it as the primary connection’s base.

# Critical Issues
No critical bugs found

# Performance Issues
No performance issues found

# Security Concerns
No security concerns found

# Suggestions for Improvements
- Add a brief comment to guide contributors (esp. those from .NET/TS) on intended usage.
  ```ruby
  # Base model for all ActiveRecord models. Do not add table-backed logic here.
  class ApplicationRecord < ActiveRecord::Base
    primary_abstract_class
  end
  ```

- Ensure all models inherit from ApplicationRecord (not directly from ActiveRecord::Base) to centralize shared behavior.
  ```ruby
  # before
  class User < ActiveRecord::Base; end

  # after
  class User < ApplicationRecord; end
  ```

- If targeting older Rails (< 7), use the legacy abstract flag for compatibility.
  ```ruby
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
  ```