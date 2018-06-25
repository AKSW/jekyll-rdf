#!/bin/sh

DIR="Jekyll"   #default values
URL="http://example.org/"
BASE="/instance"
while [ "$#" -gt "0" ]; do
  case $1 in
    -n)
      DIR=$2
      ;;
    -u)
      URL=$2
      ;;
    -b)
      BASE=$2
      ;;
    -s)
      SOURCE=$2
      ;;
    -p)
      PREFIX=$2
      ;;
  esac
  shift
  shift
done

if [ -d "$DIR" ]; then
  echo "$DIR already exists. Do want to delete it? [Y/n]:"
  read ask
  if [ $ask = "y" ] || [ $ask = "Y" ]; then
    rm -r $DIR
  else
    exit 0
  fi
fi

mkdir $DIR
RDFKNO="_data/knowledge-base.ttl"
RDFPRF="_data/Prefixes.pref"
mkdir $DIR/_data


cd $DIR

echo "baseurl: \"$BASE\" # the subpath of your site, e.g. /blog" >> _config.yml
echo "url: \"$URL\" # the base hostname & protocol for your site" >> _config.yml
echo "# Build settings" >> _config.yml
echo "markdown: kramdown" >> _config.yml
echo "plugins:" >> _config.yml
echo "- jekyll-rdf" >> _config.yml
echo "jekyll_rdf:" >> _config.yml
echo "  path: \"$RDFKNO\"" >> _config.yml
echo "  restriction: \"SELECT ?resourceUri WHERE {?resourceUri ?p ?o}\"" >> _config.yml
echo "  default_template: \"default\"" >> _config.yml
echo "  class_template_mappings:" >> _config.yml
echo "    \"http://xmlns.com/foaf/0.1/Person\": \"person\"" >> _config.yml
echo "  instance_template_mappings:" >> _config.yml
echo "    \"http://example.org/instance/resource\": \"exampleInstance\"" >> _config.yml

if [ ! -z ${SOURCE+x} ]; then
  cp ../$SOURCE $RDFKNO
else
  if [ -d "../_presets" ] && [ -f "../_presets/knowledge-base.ttl" ]; then
    cp ../_presets/knowledge-base.ttl $RDFKNO
  else
    echo "@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ." >> $RDFKNO
    echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ." >> $RDFKNO
    echo "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> ." >> $RDFKNO
    echo "@prefix foaf: <http://xmlns.com/foaf/0.1/> ." >> $RDFKNO
    echo "@prefix eg: <http://example.org/instance/> ." >> $RDFKNO
    echo "" >> $RDFKNO
    echo "eg:resource eg:predicate eg:object ." >> $RDFKNO
    echo "eg:person a foaf:Person ." >> $RDFKNO
    echo "eg:person foaf:age \"28\"^^xsd:int ." >> $RDFKNO
    echo "eg:person foaf:name \"Jeanne Doe\" ." >> $RDFKNO
  fi
fi


if [ ! -z ${PREFIX+x} ]; then
  cp ../$PREFIX $RDFPRF
else
  if [ -d "../_presets" ] && [ -f "../_presets/Prefixes.pref" ]; then
    cp ../_presets/Prefixes.pref $RDFPRF
  else
    echo "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" >> $RDFPRF
    echo "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>" >> $RDFPRF
    echo "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>" >> $RDFPRF
    echo "PREFIX foaf: <http://xmlns.com/foaf/0.1/>" >> $RDFPRF
    echo "PREFIX eg: <http://example.org/instance/>" >> $RDFPRF
  fi
fi

mkdir _layouts
cd _layouts

echo "---" >> default.html
echo "---" >> default.html
echo "<!DOCTYPE html>" >> default.html
echo "  <html>" >> default.html
echo "    <head></head>" >> default.html
echo "    <body>" >> default.html
echo "      <div>" >> default.html
echo "        <h4>This is made with jekyll-rdf</h4>" >> default.html
echo "        {{content}}" >> default.html
echo "      </div>" >> default.html
echo "    </body>" >> default.html
echo "  </html>" >> default.html

echo "---" >> person.html
echo "layout: default" >> person.html
echo "rdf_prefix_path: _data/Prefixes.pref" >> person.html
echo "---" >> person.html
echo "<div class=\"person\">" >> person.html
echo "  <h6>" >> person.html
echo "    name:" >> person.html
echo "  </h6>" >> person.html
echo "  {{page.rdf | rdf_property: \"foaf:name\"}}" >> person.html
echo "  <br/>" >> person.html
echo "  <h6>" >> person.html
echo "    age:" >> person.html
echo "  </h6>" >> person.html
echo "  {{page.rdf | rdf_property: \"foaf:age\"}}" >> person.html
echo "</div>" >> person.html

echo "---" >> exampleInstance.html
echo "layout: default" >> exampleInstance.html
echo "rdf_prefix_path: $RDFPRF" >> exampleInstance.html
echo "---" >> exampleInstance.html
echo "<div class=\"instance\">" >> exampleInstance.html
echo "  <h6> This page is mapped to: </h6>" >> exampleInstance.html
echo "  {{page.rdf}}" >> exampleInstance.html
echo "</div>" >> exampleInstance.html

cd ..
echo "source 'https://rubygems.org'" >> Gemfile

echo "group :jekyll_plugins do" >> Gemfile
echo "  gem 'jekyll-rdf', '>= 3.0.0.pre.develop.461'   #, :path => '../../../'" >> Gemfile
echo "end" >> Gemfile

