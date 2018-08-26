##
# MIT License
#
# Copyright (c) 2017 Sebastian Zänker
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

module Jekyll
  module JekyllRdf
    module Helper

      ##
      # Internal module to hold support for functionalities like submitting sparql queries
      #
      module RdfHelper
        @@prefixes = {}

        def self.sparql= sparql
          @@sparql = sparql
        end

        def self.sparql
          @@sparql
        end

        def self.site= site
          @@site = site
        end

        def self.site
          @@site
        end

        def self.page= page
          @@page = page
          unless @@page.data["rdf_prefixes"].nil?
            @@usePage = true
          else
            @@usePage = false
          end
        end

        def self.page
          @@page
        end

        def self.prefixes= path
          @@prefixes = {}
          self.load_prefixes(path, @@prefixes)
        end

        def self.load_prefixes(path, prefHolder)
          begin
            prefix_file = File.new(path).readlines
            prefHolder["rdf_prefixes"] = prefix_file.join(" ")
            prefHolder["rdf_prefix_map"] = Hash[ *(prefix_file.collect { |v|
                  arr = v.split(":",2)
                  next [nil, nil] if arr[1].nil?
                  [arr[0][7..-1].strip, arr[1].strip[1..-2]]
                }.flatten.select {|x| !x.nil?})]
          rescue Errno::ENOENT => ex
            Jekyll.logger.error("Prefix file not found: #{path}")
            raise
          end
        end

        def self.prefixes
          if(@@usePage)
            return @@page.data
          else
            return @@prefixes
          end
        end

        def self.domainiri= domain
          @@domainiri = domain
        end

        def self.domainiri
          @@domainiri
        end

        def self.pathiri= path
          @@baseiri = path
        end

        def self.pathiri
          @@baseiri
        end
      end

    end
  end
end
