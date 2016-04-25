module Jekyll

  class RdfPageData < Jekyll::Page

    def initialize(site, base, subject, graph)
      @site = site
      @base = base
      @dir = "rdfsites" #todo
      @name = subject.to_s + ".html"
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'rdf_index.html')
      self.data['title'] = subject.to_s
      graphedit = graph.query(:subject => subject)
      self.data['rdf'] = graphedit.statements.map do |statement|
      [
        statement.subject.to_s,
        statement.predicate.to_s,
        statement.object.to_s
      ]
      end
    end

  end

end
