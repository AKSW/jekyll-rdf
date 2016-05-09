module Jekyll
  class RdfProperty < Liquid::Tag

    def initialize(tag_name, property, tokens)
      super
      @property = property
    end

    def render(context)
      resource = context['page']['rdf']
      return unless resource

      p = resource.statements_as_subject.find{ |s| s.predicate.term.to_s == @property }
      return unless p

      (p.object.name).to_s
    end

  end
end

Liquid::Template.register_tag('property', Jekyll::RdfProperty)
