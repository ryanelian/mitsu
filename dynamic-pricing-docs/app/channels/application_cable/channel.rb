# This file defines the base namespace and base channel class for Action Cable (Rails' WebSocket framework).
# Think of Action Cable channels as roughly analogous to ASP.NET Core SignalR hubs:
# - A "Channel" is where you define server-side behavior for realtime pub/sub over WebSockets.
# - Clients subscribe to a channel and receive broadcasts in realtime.
# - This base class is intended to be subclassed by your actual channels (e.g., ChatChannel).
#
# File placement and autoloading:
# - Ruby's module nesting (ApplicationCable) maps to the directory structure app/channels/application_cable.
# - Rails autoloads constants using Zeitwerk, so class/module names must match file paths and casing
#   similar to how C# namespaces map to folders and TypeScript module resolution works in Next.js.
module ApplicationCable
  # Base channel class for your app's channels.
  #
  # - Inherits from ActionCable::Channel::Base, the Rails framework class that provides core channel features:
  #   - Lifecycle hooks: subscribed, unsubscribed
  #   - Streaming helpers: stream_from, stop_all_streams
  #   - Receiving data: receive (when using ActionCable's direct messages)
  #   - Error handling: rescue_from
  #
  # - You typically create subclasses like:
  #     class ChatChannel < ApplicationCable::Channel
  #       def subscribed
  #         stream_from "chat_#{params[:room_id]}"
  #       end
  #     end
  #
  # - Parallel to C#/SignalR: This is like defining your own Hub base class to share common behavior
  #   across hubs. It's also similar to having a common abstract base controller in ASP.NET Core.
  #
  # - Common use for this class:
  #   - Define helper methods or shared authorization checks for all channels.
  #   - Include shared modules.
  #   - Configure rescue_from for channel-wide error handling.
  #
  # - Connection-level auth/identification usually happens in ApplicationCable::Connection (connection.rb),
  #   similar to middleware or authentication handlers in ASP.NET Core. Channels can then access identifiers
  #   (e.g., current_user) exposed by the connection.
  class Channel < ActionCable::Channel::Base  # Inherit Rails' base to get channel DSL and lifecycle
    # Intentionally empty: this class acts as a shared base for your concrete channels.                 # no-op body
    # Add cross-cutting concerns here (e.g., helper methods, rescue_from), but keep business logic in subclasses.  # doc
    #
    # Ruby note:
    # - Class bodies are open; you can add methods here later without changing subclasses.
    # - Methods are public by default; use private/protected as needed.
    #
    # Concurrency/runtime notes:
    # - Action Cable is event-driven; do not store per-connection mutable state on class variables.
    # - Use the connection object (e.g., connection.current_user) or per-subscription instance state.
  end
end