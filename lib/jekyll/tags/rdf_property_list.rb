module Jekyll
  class RdfPropertyList < Liquid::Tag

    def initialize(tag_name, property, tokens)
      super
      @property = property
    end

    def render(context)
      resource = context['page']['rdf']
      prop = @property.split(",")
      return unless resource

      p = resource.statements_as_subject.select{ |s| s.predicate.term.to_s == prop[0] }
      return if p.empty?
      
      if prop[1] == "" || prop[1] == nil
        return p.map{|p| p.object.name}.to_s
      else
        returnstr = ""
        p.map{|p| p.object.name}.each do |n|
          returnstr = returnstr + prop[1] + n.to_s + prop[2]
        end
        return returnstr
      end
    end

  end
end

Liquid::Template.register_tag('propertyList', Jekyll::RdfPropertyList)
