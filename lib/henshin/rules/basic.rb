# Load the basic engines and include basic #rules for them.

require 'henshin/rules'
require 'henshin/engine'

%w(builder coffeescript erb haml kramdown liquid maruku nokogiri rdiscount rdoc
redcarpet redcloth sass slim).each {|l| require "henshin/engine/#{l}" }

require 'henshin/engine/support/highlighter'

module Henshin
  module Rules

    module Basic
      extend Rules

      rule '**/*.liquid' do
        apply :liquid
      end

      rule '**/*.{md,mkd,markdown}' do
        case @site.config['markdown']
          when 'maruku' then apply :maruku
          when 'kramdown' then apply :kramdown
          when 'rdiscount' then apply :rdiscount
        else
          apply :maruku
        end
      end

      rule '**/*.{erb,rhtml}' do
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
end
