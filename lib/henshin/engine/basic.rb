# Load the basic filters and include basic #renders for them.

require_relative '../definitions'
%w(coffeescript erb haml liquid maruku redcloth sass).each do |l|
  require_relative l
end



module Henshin

  module BasicRender
    include RenderDefinition
  
    render '**/*.liquid' do
      apply Liquid
    end
    
    render '**/*.{md,mkd,markdown}' do
      apply Maruku
    end

    render '**/*.erb' do
      apply Erb
    end
    
    render '**/*.haml' do
      apply Haml
    end
    
    render '**/*.textile' do
      apply RedCloth
    end
    
    render '**/*.sass' do
      apply Sass
      
      set :output, 'css'
      set :layout, false
    end
    
    render '**/*.scss' do
      apply Scss
      
      set :output, 'css'
      set :layout, false
    end
    
    render '**/*.coffee' do
      apply CoffeeScript
      
      set :output, 'js'
      set :layout, false
    end
  
  end
end