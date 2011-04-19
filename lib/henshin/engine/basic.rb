# Load the basic filters and include basic #rules for them.

require_relative '../rules'
%w(coffeescript erb haml liquid maruku redcloth sass builder nokogiri 
rdoc).each do |l|
  require_relative l
end

require_relative 'support/highlighter'

module Henshin

  module BasicRules
    extend Rules
  
    rule '**/*.liquid' do
      apply :liquid
    end
    
    rule '**/*.{md,mkd,markdown}' do
      apply :maruku
    end

    rule '**/*.erb' do
      apply :erb
    end
    
    rule '**/*.haml' do
      apply :haml
    end
    
    rule '**/*.textile' do
      apply :redcloth
    end
    
    rule '**/*.rdoc' do
      apply :rdoc
    end
    
    rule '**/*.builder' do
      apply :builder
      
      set :output, 'xml'
      set :layout, false
    end
    
    rule '**/*.nokogiri' do
      apply :nokogiri
      
      set :output, 'xml'
      set :layout, false
    end
    
    rule '**/*.sass' do
      apply :sass
      
      set :output, 'css'
      set :layout, false
    end
    
    rule '**/*.scss' do
      apply :scss
      
      set :output, 'css'
      set :layout, false
    end
    
    rule '**/*.coffee' do
      apply :coffeescript
      
      set :output, 'js'
      set :layout, false
    end
  
  end
end