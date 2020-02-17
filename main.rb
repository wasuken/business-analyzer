# coding: utf-8
require "nokogiri"
require 'open-uri'
require "net/http"
require "natto"
require 'robotex'

NM = Natto::MeCab.new
ROBOTEX = Robotex.new "Crawler"

def green_analyze(url)
  charset = nil

  html = open(url) do |f|
    charset = f.charset
    f.read
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)
  doc.css("#content_cont").each do |node|
    node = NM.enum_parse(node.text.gsub(/<.*?>/, ''))
             .select{|n| n.surface.size > 2 }
             .select{|n| n.feature.include?('名詞')}
             .group_by{|n| n.surface }
             .sort{|a, b| a[1].size <=> b[1].size}
             .reverse

    node.take(20).each{|a|
      p "surface:#{a[0]}, count:#{a[1].size}"
    }
  end
end

url = ""
if ARGV.size == 1
  url = ARGV[0]
else
  url = gets.chomp
end

uri = URI.parse(url)
base "#{uri.scheme}://#{uri.host}"

if url.include?("green-japan.com") && robotex.allowed?(base)
  green_analyze(url)
else
  p "not run."
end
