##
# MIT License
#
# Copyright (c) 2016 Elias Saalmann, Christian Frommert, Simon Jakobi,
# Arne Jonas Präger, Maxi Bornmann, Georg Hackel, Eric Füg
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

module Jekyll #:nodoc:
  module Drops #:nodoc:

    ##
    # Represents an RDF resource to the Liquid template engine
    #
    class RdfResource < RdfTerm

      ##
      # The Jekyll::Site of this Jekyll::Drops::RdfResource
      #
      attr_accessor :site

      ##
      # The Jekyll::RdfPageData of this Jekyll::Drops::RdfResource
      #
      attr_accessor :page

      ##
      #
      #
      attr_accessor :subResources

      ##
      #
      #
      attr_reader :covered

      ##
      #
      #
      def initialize(term, site = nil, page = nil, covered = false)
        super(term)
        if(site.is_a?(Jekyll::Site))
          @site = site
        end
        if(page.is_a?(Jekyll::Page))
          @page = page
        end
        @subResources = {}
        @covered = covered
      end

      def add_necessities(site, page)
        if(site.is_a?(Jekyll::Site))
          @site ||= site
        end
        if(page.is_a?(Jekyll::Page))
          @page ||= page
        end
        return self
      end

      def ready?
        return (@site.is_a?(Jekyll::Site)||@page.is_a?(Jekyll::Page))
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose subject, predicate or object is the RDF resource represented by the receiver
      #
      def statements
        @statements ||= statements_as_subject + statements_as_predicate + statements_as_object
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose subject is the RDF resource represented by the receiver
      #
      def statements_as_subject
        @statements_as_subject ||= statements_as :subject
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose predicate is the RDF resource represented by the receiver
      #
      def statements_as_predicate
        @statements_as_predicate ||= statements_as :predicate
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose object is the RDF resource represented by the receiver
      #
      def statements_as_object
        @statements_as_object ||= statements_as :object
      end

      ##
      # Return a filename corresponding to the RDF resource represented by the receiver. The mapping between RDF resources and filenames should be bijective.
      #
      def filename(domain_name, baseurl)
        @filename ||= generate_file_name(domain_name, baseurl)
      end

      def direct_classes
        @direct_classes ||= begin
          classes=[]
          selection = statements_as(:subject).select{ |s| s.predicate.term.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" }
          unless selection.empty?
            selection.each{|s| classes << s.object.term.to_s}
          end
          classes.uniq!
          classes
        end
      end

      def iri
        term.to_s
      end

      ##
      # Return the URL of the page representing this RdfResource
      #
      def page_url
	    return @page_url unless @page_url.nil?
        generate_file_name(@site.config["url"], @site.config["baseurl"])
		@page_url
      end

      ##
      # Return the path to the page representing this RdfResource
      #
      def render_path
        return @render_path unless @page_url.nil?
        generate_file_name(@site.config["url"], @site.config["baseurl"])
		@render_path
      end

      ##
      # Return a list of RDF statements where the represented RDF resource plays a role
      # * +role+ - which role the represented RDF resource should play:
      #   :subject ::
      #     Return a list of Jekyll::Drops::RdfStatements whose subject is the RDF resource represented by the receiver
      #   :predicate ::
      #     Return a list of Jekyll::Drops::RdfStatements whose predicate is the RDF resource represented by the receiver
      #   :object ::
      #     Return a list of Jekyll::Drops::RdfStatements whose object is the RDF resource represented by the receiver
      #
      def statements_as(role)
        if(!term.to_s[0..1].eql? "_:")
          input_uri = "<#{term.to_s}>"
        elsif(:predicate.eql? role)
          return []
        else
          input_uri = term.to_s
        end

        case role
          when :subject
            query = "SELECT ?p ?o ?dt ?lit ?lang WHERE{ #{input_uri} ?p ?o BIND(datatype(?o) AS ?dt) BIND(isLiteral(?o) AS ?lit) BIND(lang(?o) AS ?lang)}"
            Jekyll::RdfHelper::sparql.query(query).map do |solution|
              check = check_solution(solution)
              create_statement(term.to_s, solution.p, solution.o, solution.lit, check[:lang], check[:data_type])
            end
          when :predicate
            query = "SELECT ?s ?o ?dt ?lit ?lang WHERE{ ?s #{input_uri} ?o BIND(datatype(?o) AS ?dt) BIND(isLiteral(?o) AS ?lit) BIND(lang(?o) AS ?lang)}"
            Jekyll::RdfHelper::sparql.query(query).map do |solution|
              check = check_solution(solution)
              create_statement(solution.s, term.to_s, solution.o, solution.lit, check[:lang], check[:data_type])
            end
          when :object
            query = "SELECT ?s ?p WHERE{ ?s ?p #{input_uri}}"
            Jekyll::RdfHelper::sparql.query(query).map do |solution|
              create_statement( solution.s, solution.p, term.to_s)
            end
          else
            Jekyll.logger.error "Not existing role found in #{term.to_s}"
            return
        end
      end

      def inspect
        obj_id = ('%x' % (self.object_id << 1)).to_s
        return "#<RdfResource:0x#{"0"*(14 - obj_id.length)}#{obj_id} @iri=#{iri} @subResources=[#{subResources.map { |x| x.inspect}.join(", ")}]>"
      end

      #checks if a query solution contains a language or type tag and returns those in a hash
      private
      def check_solution(solution)
        result = {:lang => nil, :data_type => nil}
        if((solution.bound?(:lang)) && (!solution.lang.to_s.eql?("")))
          result[:lang] = solution.lang.to_s.to_sym
        end
        if(solution.bound? :dt)
          result[:data_type] = solution.dt
        end
        return result
      end

      private
      def create_statement(subject_string, predicate_string, object_string, is_lit = nil, lang = nil, data_type = nil)
        subject = RDF::URI(subject_string)
        predicate = RDF::URI(predicate_string)
        if(!is_lit.nil?&&is_lit.true?)
          object = RDF::Literal(object_string, language: lang, datatype: RDF::URI(data_type))
        else
          object = RDF::URI(object_string)
        end
        return RdfStatement.new(RDF::Statement( subject, predicate, object), @site)
      end

      private
      ##
      # Generate a filename corresponding to the RDF resource represented by the receiver. The mapping between RDF resources and filenames should be bijective. If the url of the rdf is the same as of the hosting site it will be omitted.
      # * +domain_name+
      #
      def generate_file_name(domain_name, baseurl)
        if(term.to_s[0..1].eql? "_:")
          file_name = "rdfsites/blanknode/#{term.to_s.gsub('_:','blanknode_')}/" # ':' can not be used on windows
        else
          begin
            uri = Addressable::URI.parse(term.to_s).to_hash
            file_name = "rdfsites/" # in this directory all external RDF sites are stored
            if((uri[:host].eql? domain_name) || ("#{uri[:scheme]}://#{uri[:host]}".eql? domain_name))
              file_name = "/"
              uri[:scheme] = nil
              uri[:host] = nil
              if(uri[:path].length > baseurl.length)
                if(uri[:path][0..(baseurl.length)].eql? (baseurl + "/"))
                  uri[:path] = uri[:path][(baseurl.length)..-1]
                end
              elsif(uri[:path].eql?(baseurl))
                uri[:path] = nil
              end
            end
            #An URI consists of these fields [:scheme, :userinfo, :host, :port, :registry, :path, :opaque, :query, :fragment]
            file_name << "#{uri[:scheme]}/" unless uri[:scheme].nil?
            file_name << "#{uri[:userinfo]}@" unless uri[:userinfo].nil?
            file_name << "#{uri[:host]}/" unless uri[:host].nil?
            file_name << "#{uri[:port]}/" unless uri[:port].nil?
            # registry purpose unknown
            file_name << "#{uri[:path][1..-1]}" unless uri[:path].nil?
            # opaque jekyll produces static pages, so we do not dereferencing
            # query queries do not address resources
            # file_name << "#/#{uri[:fragment]}" unless uri[:fragment].nil? fragments are not evaluated by browsers, only by clients
          rescue Addressable::URI::InvalidURIError => x
            file_name = "invalids/#{term.to_s}"
            Jekyll.logger.error("Invalid resource found: #{term.to_s} is not a proper uri")
            Jekyll.logger.error("URI parser exited with message: #{x.message}")
          end
        end
        # windows compatibility
        file_name = file_name.gsub('//','/') # needs a better regex to include /// ////...
        file_name = file_name.strip
        if(file_name[-2..-1] == "#/")
          file_name = file_name[0..-3]
        end
        if(file_name[-1] == '/')
          file_name << "index.html"
        else
          last_slash = file_name.rindex('/')
		  ending = ""
		  if(file_name[-5..-1].eql? ".html")
		    ending = ".html" #in case .html is already contained by the term.url
		  else
            file_name[last_slash..-1] = "#{file_name[last_slash..-1]}.html"
		  end
        end
        @render_path = file_name
        @page_url = "#{file_name.chomp('index.html').chomp('.html')}#{ending}"
        file_name
      end
    end
  end
end
