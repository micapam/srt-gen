require 'facets/string/shatter'
require 'date'
require 'active_support/time'
require 'trollop'

def get_time(str)
  DateTime.strptime(str, '%H:%M:%S')
end

opts = Trollop::options do
  opt :source_file, 'Source file', :short => 's', :type => :string
end

Trollop::die :source_file, 'not specified' unless opts[:source_file]
Trollop::die :source_file, 'does not exist' unless File.exist? opts[:source_file]

time_pattern = /([0-9]{2}:){3}/
source = File.open(opts[:source_file], 'r') { |file| file.read }
parts = source.shatter(time_pattern)
current_node = nil
last_node = nil
subs = []

parts.each_with_index do |part, idx|
  if idx % 2 == 0
    # time value
    time = get_time(part)
    last_node = current_node unless current_node.nil?
    current_node = { :time_begin => time }
    last_node[:time_end] = time - 1.second unless last_node.nil?
    subs << current_node
  else
    # subtitle value
    current_node[:text] = part.strip
  end
end

current_node[:time_end] = current_node[:time_begin] + 3.seconds

out = []

subs.each_with_index do |node, idx|
  puts idx
  puts "#{node[:time_begin].strftime('%H:%M:%S')},000 --> #{node[:time_end].strftime('%H:%M:%S')},750"
  puts node[:text].gsub(/^[A-Za-z +]+: ["\u201C\u201D\u201E\u201F\u2033\u2036]?/, '').gsub(/["\u201C\u201D\u201E\u201F\u2033\u2036]$/, '')
  puts ''
end
