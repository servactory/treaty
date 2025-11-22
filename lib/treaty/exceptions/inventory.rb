# frozen_string_literal: true

module Treaty
  module Exceptions
    # Raised when inventory definition or processing fails
    #
    # ## Purpose
    #
    # Indicates errors during inventory DSL processing, including invalid method calls,
    # missing parameters, and invalid source types. Provides consistent error handling
    # for the inventory system.
    #
    # ## Usage
    #
    # Raised in various inventory scenarios:
    #
    # ### Invalid DSL Method
    # ```ruby
    # # When calling unknown method in treaty block
    # treaty :index do
    #   unknown_method :something
    # end
    # # => Treaty::Exceptions::Inventory: Unknown method 'unknown_method' in treaty block for action 'index'
    # ```
    #
    # ### Missing Required Parameters
    # ```ruby
    # # When 'from' parameter is missing
    # treaty :index do
    #   provide :posts
    # end
    # # => Treaty::Exceptions::Inventory: Inventory 'posts' requires 'from' parameter
    #
    # # When inventory name is not a symbol
    # treaty :index do
    #   provide "posts", from: :load_posts
    # end
    # # => Treaty::Exceptions::Inventory: Inventory name must be a Symbol, got "posts"
    # ```
    #
    # ### Invalid Source
    # ```ruby
    # # When source is nil
    # treaty :index do
    #   provide :posts, from: nil
    # end
    # # => Treaty::Exceptions::Inventory: Inventory source cannot be nil
    # ```
    #
    # ## Integration
    #
    # Can be rescued by application controllers:
    #
    # ```ruby
    # rescue_from Treaty::Exceptions::Inventory, with: :render_inventory_error
    #
    # def render_inventory_error(exception)
    #   render json: { error: exception.message }, status: :internal_server_error
    # end
    # ```
    #
    # ## Valid Sources
    #
    # - Symbol: Method name to call on controller (e.g., `:load_posts`)
    # - Proc/Lambda: Callable object (e.g., `-> { Post.all }`)
    # - Direct value: String, number, or any other value (e.g., `"Welcome"`)
    class Inventory < Base
    end
  end
end
