require 'rubygems'
require 'yaml'
require 'pp'

l1 = "#{ARGV[0]}en.yml"
l2 = "#{ARGV[0]}in.yml"

first = YAML.load_file("config/locales/#{l1}")
second = YAML.load_file("config/locales/#{l2}")

def diff(root, compared, structure = [])
  root.each_key do |key|
    next_root     = root[key]
    next_compared = compared.nil? ? nil : compared[key]
    new_structure = structure.dup << key
    puts "#{new_structure.join('.')}" if compared.nil? || compared[key].nil?
    diff(next_root, next_compared, new_structure) if next_root.kind_of? Hash
  end
end

puts "MISSING FROM #{l2}"
diff(first['en'], second['in'], ['in'])

puts "\nMISSING FROM #{l1}"
diff(second['in'], first['en'], ['en'])