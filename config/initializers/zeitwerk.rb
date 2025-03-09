Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "litefs" => "LiteFS",
  )
end
