module Jekyll
  class RdfProperty < Liquid::Tag

    def initialize(tag_name, params, tokens)
      super
      @params = params.split(",")
    end

    def render(context)
      resource = context['page']['rdf']
      return unless resource

      config = resource.site.config.fetch('jekyll_rdf')
      lang = @params[1] || config['language']

      results = resource.statements_as_subject.select{ |s| s.predicate.term.to_s == @params[0] }
      if results.count > 1 && results.first.object.term.is_a?(RDF::Term)
        p = results.find{ |s| s.object.term.language == lang.to_sym }
      end
      p = results.first unless p
      return unless p

      (p.object.name).to_s
    end

  end
end

Liquid::Template.register_tag('property', Jekyll::RdfProperty)
