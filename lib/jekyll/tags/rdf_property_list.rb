module Jekyll
  class RdfPropertyList < Liquid::Tag

    def initialize(tag_name, property, tokens)
      super
      @property = property
    end

    def render(context)
      resource = context['page']['rdf']
      return unless resource

      p = resource.statements_as_subject.select{ |s| s.predicate.term.to_s == @property }
      return if p.empty?

      p.map{|p| p.object.name}.to_s
    end

  end
end

Liquid::Template.register_tag('propertyList', Jekyll::RdfPropertyList)
