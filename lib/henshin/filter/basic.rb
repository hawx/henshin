# Load the basic filters and include basic #renders for them.

%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
  require_relative l
end

require_relative '../definitions'

module Henshin

  module BasicRender
    include RenderDefinition
  
    render '**/*.liquid' do
      apply LiquidEngine
    end
    
    render '**/*.(md|mkd|markdown)' do
      apply MarukuEngine
    end
    
    render '**/*.sass' do
      apply SassEngine
    end
    
    render '**/*.scss' do
      apply ScssEngine
    end
    
    render '**/*.coffee' do
      apply CoffeeScriptEngine
    end
    
    render '**/*.erb' do
      apply ErbEngine
    end
    
    render '**/*.haml' do
      apply HamlEngine
    end
    
    render '**/*.textile' do
      apply RedClothEngine
    end
  
  end
end