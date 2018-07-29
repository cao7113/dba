#!/usr/bin/env ruby

require 'open-uri'

open("http://openconcept.ca/sites/openconcept.ca/files/country_code_drupal_0.txt") do |countries|
  countries.read.each_line do |country|
    code, name = country.chomp.split("|")
    puts "#{code}, #{name}"
  end
end
