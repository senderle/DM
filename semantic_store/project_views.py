from django.db import transaction
from django.http import HttpResponse, HttpResponseNotFound

from rdflib.graph import Graph
from rdflib.exceptions import ParserError
from rdflib import Literal

from semantic_store.rdfstore import rdfstore
from semantic_store.namespaces import NS, ns, bind_namespaces
from semantic_store import uris

from datetime import datetime


def create_project_from_request(request):
    host =  request.get_host()
    g = Graph()
    bind_namespaces(g)
    try:
        g.parse(data=request.body)
    except:
        return HttpResponse(status=400, content="Unable to parse serialization.")

    query = g.query("""SELECT ?uri ?user
                    WHERE {
                        ?user perm:hasPermissionOver ?uri .
                    }""", initNs = ns)

    for uri, user in query:
        with transaction.commit_on_success():
            username = user.split("/")[-1]

            allprojects_uri = uris.uri('semantic_store_projects')
            allprojects_g = Graph(store=rdfstore(), identifier=allprojects_uri)
            bind_namespaces(allprojects_g)

            project_uri = uris.uri('semantic_store_projects', uri=uri)
            project_g = Graph(store=rdfstore(), identifier=project_uri)
            bind_namespaces(project_g)

            for t in g.triples((uri, None, None)):
                allprojects_g.add(t)
                project_g.add(t)

            url = uris.url(host, 'semantic_store_projects', uri=uri)
            allprojects_g.set((project_uri, NS.ore['isDescribedBy'], url))
            project_g.set((uri, NS.dcterms['created'], Literal(datetime.utcnow())))

        create_project_user_graph(host, username, uri)


# Restructured read_project
# Previously, when hitting multiple project urls in quick succession, a 500 
#  error occurred occassionally since the graph with the information about
#  all projects wasn't closed before the next url was hit
def read_project(request, uri):
    uri = uris.uri('semantic_store_projects', uri=uri)
    project_g = Graph(store=rdfstore(), identifier=uri)

    print "Reading project using graph identifier %s" % uri
    
    if len(project_g) >0:
        return HttpResponse(project_g.serialize(), mimetype='text/xml')
    else:
        return HttpResponseNotFound()


def update_project(request, uri):
    input_graph = Graph()
    bind_namespaces(input_graph)

    try:
        input_graph.parse(data=request.body)
    except ParserError as e:
        return HttpResponse(status=400, content="Unable to parse serialization.\n%s" % e)

    project_graph = update_project_graph(input_graph, uri)

    return HttpResponse(project_graph.serialize(), status=201, mimetype='text/xml')

def update_project_graph(g, identifier):
    with transaction.commit_on_success():
        uri = uris.uri('semantic_store_projects', uri=identifier)
        print "Updating project using graph identifier %s" % uri
        project_g = Graph(store=rdfstore(), identifier=uri)
        bind_namespaces(project_g)

        for triple in g:
            project_g.add(triple)

        return project_g

def delete_project(request, uri):
    # Not implemented
    return HttpResponse(status=501)

# Creates a graph identified by user of the projects belonging to the user, which
#  can be found at the descriptive url of the user (/store/user/<username>)
# The graph houses the uri of all of the user's projects and the url where more info
#  can be found about each project
def create_project_user_graph(host, user, project):
    with transaction.commit_on_success():
        user_uri = uris.uri('semantic_store_users', username=user)
        g = Graph(store=rdfstore(), identifier = user_uri)
        bind_namespaces(g)
        g.add((project, NS.ore['isDescribedBy'], uris.url(host, "semantic_store_projects", uri=project)))

        # Permissions triple allows read-only permissions if/when necessary
        # <http://vocab.ox.ac.uk/perm/index.rdf> for definitions
        # Perhaps we stop using ore:aggregates and use perm:hasPermissionOver and
        #  its subproperties since they are better definitions in this instance?
        #  
        #  (tandres) agreed. Users should actually be foaf:Agents which have permission over projects
        g.add((user_uri, NS.perm['hasPermissionOver'], project))
        g.add((user_uri, NS.perm['mayRead'], project))
        g.add((user_uri, NS.perm['mayUpdate'], project))
        g.add((user_uri, NS.perm['mayDelete'], project))
        g.add((user_uri, NS.perm['mayAugment'], project))
        g.add((user_uri, NS.perm['mayAdminister'], project))

        g.add((user_uri, NS.rdf['type'], NS.foaf['Agent']))
        return g.serialize()


