# frozen_string_literal: true
# The "frozen_string_literal" magic comment is a common Ruby optimization that makes all string
# literals in this file immutable (similar in spirit to using readonly string constants in C#/TS).
# It is safe to include and does not change runtime behavior of this class.

# ApplicationCable is a Ruby module acting as a namespace.
# - Ruby modules are similar to C# namespaces or TS namespaces, but can also hold methods/mixins.
# - Rails autoloading maps this path (app/channels/application_cable/connection.rb)
#   to the constant ApplicationCable::Connection by convention.
# - Anything under app/channels/application_cable is the standard place for framework-level
#   Action Cable setup shared by your app's channels.
module ApplicationCable # Begin namespace (similar to C# namespace ApplicationCable)
  # Connection is the entry point for every WebSocket connection in Rails' Action Cable.
  # - In ASP.NET Core + SignalR terms: this sits "below" your Hub. It's where you authenticate,
  #   identify the client (e.g., current_user), and decide whether to accept or reject a socket.
  # - In a typical Rails app, you would override:
  #     identified_by :current_user
  #     def connect
  #       self.current_user = find_verified_user
  #     end
  #     def disconnect; end
  #   But this skeleton intentionally does none of that, so every socket is accepted without
  #   identification or authentication logic at the connection layer.
  #
  # Inheritance:
  # - ActionCable::Connection::Base is provided by Rails and implements the WebSocket handshake,
  #   lifecycle, and thread management for each connection.
  # - Each physical WebSocket gets its own Connection instance (roughly similar to one Hub
  #   connection instance per client in SignalR).
  #
  # Lifecycle (if you add methods later; none are defined now, preserving behavior):
  # - connect: called when the socket is established. Use it to authenticate/identify.
  # - disconnect: called when the socket closes. Use it to clean up resources.
  #
  # Data available within a Connection (again, not used here, but commonly leveraged):
  # - cookies, cookies.signed: read auth tokens set by your HTTP app.
  # - request: access to Rack request env (headers, IP, etc.).
  # - params: query string params from the WebSocket URL.
  #
  # Security note:
  # - Because this class is empty, it does not reject any connections. Channels may still
  #   authorize subscription-level access, but connection-level identity is absent.
  #
  # Concurrency:
  # - Action Cable runs each connection in its own thread. Avoid blocking calls inside
  #   connect/disconnect in real apps, or offload to background jobs.
  class Connection < ActionCable::Connection::Base # Inherit framework behavior; no overrides here
  end # class Connection

end # module ApplicationCable