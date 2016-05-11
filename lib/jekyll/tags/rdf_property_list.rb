module Jekyll
  class RdfPropertyList < Liquid::Tag

    def initialize(tag_name, params, tokens)
      super
      @params = params.split(",")
    end

    def render(context)
      resource = context['page']['rdf']
      return unless resource

      p = resource.statements_as_subject.select{ |s| s.predicate.term.to_s == @params[0] }
      return if p.empty?
      
      if @params[1] == "" || @params[1] == nil
        return p.map{|p| p.object.name}.to_s
      else
        returnstr = ""
        p.map{|p| p.object.name}.each do |n|
          returnstr = returnstr + @params[1] + n.to_s + @params[2]
        end
        return returnstr
      end
    end

  end
end

Liquid::Template.register_tag('propertyList', Jekyll::RdfPropertyList)
