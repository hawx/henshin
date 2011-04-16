# Load the basic filters and include basic #rules for them.

require_relative '../rules'
%w(coffeescript erb haml liquid maruku redcloth sass builder nokogiri rdoc).each do |l|
  require_relative l
end

require_relative 'support/highlighter'

module Henshin

  module BasicRules
    extend Rules
  
    rule '**/*.liquid' do
      apply Engine::Liquid
    end
    
    rule '**/*.{md,mkd,markdown}' do
      apply Engine::Maruku
    end

    rule '**/*.erb' do
      apply Engine::Erb
    end
    
    rule '**/*.haml' do
      apply Engine::Haml
    end
    
    rule '**/*.textile' do
      apply Engine::RedCloth
    end
    
    rule '**/*.rdoc' do
      apply Engine::RDoc
    end
    
    rule '**/*.builder' do
      apply Engine::Builder
      
      set :output, 'xml'
      set :layout, false
    end
    
    rule '**/*.nokogiri' do
      apply Engine::Nokogiri
      
      set :output, 'xml'
      set :layout, false
    end
    
    rule '**/*.sass' do
      apply Engine::Sass
      
      set :output, 'css'
      set :layout, false
    end
    
    rule '**/*.scss' do
      apply Engine::Scss
      
      set :output, 'css'
      set :layout, false
    end
    
    rule '**/*.coffee' do
      apply Engine::CoffeeScript
      
      set :output, 'js'
      set :layout, false
    end
  
  end
end