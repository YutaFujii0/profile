require "middleman-core"

Middleman::Extensions.register :middleman-my_extension do
  require "my-extension/extension"
  MyExtension
end
