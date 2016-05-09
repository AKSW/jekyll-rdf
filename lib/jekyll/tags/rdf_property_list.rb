module Jekyll
  class RdfPropertyList < Liquid::Tag

    def initialize(tag_name, params, tokens)
      super
      @params = params
    end

    def render(context)
      resource = context['page']['rdf']
      param = @params.split(",")
      return unless resource

      p = resource.statements_as_subject.select{ |s| s.predicate.term.to_s == param[0] }
      return if p.empty?
      
      if param[1] == "" || param[1] == nil
        return p.map{|p| p.object.name}.to_s
      else
        returnstr = ""
        p.map{|p| p.object.name}.each do |n|
          returnstr = returnstr + param[1] + n.to_s + param[2]
        end
        return returnstr
      end
    end

  end
end

Liquid::Template.register_tag('propertyList', Jekyll::RdfPropertyList)
