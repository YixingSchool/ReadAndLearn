# NetworkX入门教程

* [Creating a graph — NetworkX 1.11 documentation ](https://networkx.readthedocs.io/en/stable/tutorial/tutorial.html#graph-attributes)
* [networkx/tutorial.rst at v1.11 · networkx/networkx ](https://github.com/networkx/networkx/blob/v1.11/doc/source/tutorial/tutorial.rst)


<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [NetworkX入门教程](#networkx入门教程)
* [创建图](#创建图)
* [节点](#节点)
* [边](#边)
* [图的属性](#图的属性)
* [有向图](#有向图)
* [分析图](#分析图)
* [绘图](#绘图)

<!-- /code_chunk_output -->


学习NetworkX从这里开始

# 创建图
创建一个没有节点、没有边的空图

```py
>>> import networkx as nx
>>> G=nx.Graph()
```

根据定义，图是节点（顶点）以及特定的节点对（边、链接等）的集合，。在NetworkX，节点可以是任何哈希对象(hashable object)如文本字符串、图像、XML对象，另一个图，一个定制的节点对象，等（注：Python的`None对象`不应该作为一个节点，作为是否可选的功能已经在许多功能有争论。）

# 节点

可以用几种方式修改图G。NetworkX包含许多生成图的功能和函数来读写多种形式。我们通过简单的例子作为开始。你可以一次添加一个节点：

```py
>>> G.add_node(1)
```

添加节点列表

```py
>>> G.add_nodes_from([2,3])
```

or add any nbunch of nodes. An nbunch is any iterable container of nodes that is not itself a node in the graph. (e.g. a list, set, graph, file, etc..)

添加[nbunch](https://networkx.readthedocs.io/en/stable/reference/glossary.html#term-nbunch)节点。一个nbunch节点是节点的容器，本身不是图中的一个节点。（例如列表、集合、图形、文件等。）

```py
import networkx as nx
import matplotlib.pyplot as plt
G=nx.Graph()
H=nx.path_graph(10)
G.add_nodes_from(H)
nx.draw(G)
plt.show()
```
Note that G now contains the nodes of H as nodes of G. In contrast, you could use the graph H as a node in G.

>>> G.add_node(H)
The graph G now contains H as a node. This flexibility is very powerful as it allows graphs of graphs, graphs of files, graphs of functions and much more. It is worth thinking about how to structure your application so that the nodes are useful entities. Of course you can always use a unique identifier in G and have a separate dictionary keyed by identifier to the node information if you prefer. (Note: You should not change the node object if the hash depends on its contents.)

# 边

Edges
G can also be grown by adding one edge at a time,

>>> G.add_edge(1,2)
>>> e=(2,3)
>>> G.add_edge(*e) # unpack edge tuple*
by adding a list of edges,

>>> G.add_edges_from([(1,2),(1,3)])
or by adding any ebunch of edges. An ebunch is any iterable container of edge-tuples. An edge-tuple can be a 2-tuple of nodes or a 3-tuple with 2 nodes followed by an edge attribute dictionary, e.g. (2,3,{‘weight’:3.1415}). Edge attributes are discussed further below

>>> G.add_edges_from(H.edges())
One can demolish the graph in a similar fashion; using Graph.remove_node(), Graph.remove_nodes_from(), Graph.remove_edge() and Graph.remove_edges_from(), e.g.

>>> G.remove_node(H)
There are no complaints when adding existing nodes or edges. For example, after removing all nodes and edges,

>>> G.clear()
we add new nodes/edges and NetworkX quietly ignores any that are already present.

>>> G.add_edges_from([(1,2),(1,3)])
>>> G.add_node(1)
>>> G.add_edge(1,2)
>>> G.add_node("spam")       # adds node "spam"
>>> G.add_nodes_from("spam") # adds 4 nodes: 's', 'p', 'a', 'm'
At this stage the graph G consists of 8 nodes and 2 edges, as can be seen by:

>>> G.number_of_nodes()
8
>>> G.number_of_edges()
2
We can examine them with

>>> G.nodes()
['a', 1, 2, 3, 'spam', 'm', 'p', 's']
>>> G.edges()
[(1, 2), (1, 3)]
>>> G.neighbors(1)
[2, 3]
Removing nodes or edges has similar syntax to adding:

>>> G.remove_nodes_from("spam")
>>> G.nodes()
[1, 2, 3, 'spam']
>>> G.remove_edge(1,3)
When creating a graph structure by instantiating one of the graph classes you can specify data in several formats.

>>> H=nx.DiGraph(G)   # create a DiGraph using the connections from G
>>> H.edges()
[(1, 2), (2, 1)]
>>> edgelist=[(0,1),(1,2),(2,3)]
>>> H=nx.Graph(edgelist)
What to use as nodes and edges
You might notice that nodes and edges are not specified as NetworkX objects. This leaves you free to use meaningful items as nodes and edges. The most common choices are numbers or strings, but a node can be any hashable object (except None), and an edge can be associated with any object x using G.add_edge(n1,n2,object=x).

As an example, n1 and n2 could be protein objects from the RCSB Protein Data Bank, and x could refer to an XML record of publications detailing experimental observations of their interaction.

We have found this power quite useful, but its abuse can lead to unexpected surprises unless one is familiar with Python. If in doubt, consider using convert_node_labels_to_integers() to obtain a more traditional graph with integer labels.

Accessing edges
In addition to the methods Graph.nodes(), Graph.edges(), and Graph.neighbors(), iterator versions (e.g. Graph.edges_iter()) can save you from creating large lists when you are just going to iterate through them anyway.

Fast direct access to the graph data structure is also possible using subscript notation.

Warning

Do not change the returned dict–it is part of the graph data structure and direct manipulation may leave the graph in an inconsistent state.
>>> G[1]  # Warning: do not change the resulting dict
{2: {}}
>>> G[1][2]
{}
You can safely set the attributes of an edge using subscript notation if the edge already exists.

>>> G.add_edge(1,3)
>>> G[1][3]['color']='blue'
Fast examination of all edges is achieved using adjacency iterators. Note that for undirected graphs this actually looks at each edge twice.

>>> FG=nx.Graph()
>>> FG.add_weighted_edges_from([(1,2,0.125),(1,3,0.75),(2,4,1.2),(3,4,0.375)])
>>> for n,nbrs in FG.adjacency_iter():
...    for nbr,eattr in nbrs.items():
...        data=eattr['weight']
...        if data<0.5: print('(%d, %d, %.3f)' % (n,nbr,data))
(1, 2, 0.125)
(2, 1, 0.125)
(3, 4, 0.375)
(4, 3, 0.375)
Convenient access to all edges is achieved with the edges method.

>>> for (u,v,d) in FG.edges(data='weight'):
...     if d<0.5: print('(%d, %d, %.3f)'%(n,nbr,d))
(1, 2, 0.125)
(3, 4, 0.375)
Adding attributes to graphs, nodes, and edges
Attributes such as weights, labels, colors, or whatever Python object you like, can be attached to graphs, nodes, or edges.

Each graph, node, and edge can hold key/value attribute pairs in an associated attribute dictionary (the keys must be hashable). By default these are empty, but attributes can be added or changed using add_edge, add_node or direct manipulation of the attribute dictionaries named G.graph, G.node and G.edge for a graph G.

# 图的属性

Graph attributes
Assign graph attributes when creating a new graph

>>> G = nx.Graph(day="Friday")
>>> G.graph
{'day': 'Friday'}
Or you can modify attributes later

>>> G.graph['day']='Monday'
>>> G.graph
{'day': 'Monday'}
Node attributes
Add node attributes using add_node(), add_nodes_from() or G.node

>>> G.add_node(1, time='5pm')
>>> G.add_nodes_from([3], time='2pm')
>>> G.node[1]
{'time': '5pm'}
>>> G.node[1]['room'] = 714
>>> G.nodes(data=True)
[(1, {'room': 714, 'time': '5pm'}), (3, {'time': '2pm'})]
Note that adding a node to G.node does not add it to the graph, use G.add_node() to add new nodes.

Edge Attributes
Add edge attributes using add_edge(), add_edges_from(), subscript notation, or G.edge.

>>> G.add_edge(1, 2, weight=4.7 )
>>> G.add_edges_from([(3,4),(4,5)], color='red')
>>> G.add_edges_from([(1,2,{'color':'blue'}), (2,3,{'weight':8})])
>>> G[1][2]['weight'] = 4.7
>>> G.edge[1][2]['weight'] = 4
The special attribute ‘weight’ should be numeric and holds values used by algorithms requiring weighted edges.

# 有向图
Directed graphs
The DiGraph class provides additional methods specific to directed edges, e.g. DiGraph.out_edges(), DiGraph.in_degree(), DiGraph.predecessors(), DiGraph.successors() etc. To allow algorithms to work with both classes easily, the directed versions of neighbors() and degree() are equivalent to successors() and the sum of in_degree() and out_degree() respectively even though that may feel inconsistent at times.

>>> DG=nx.DiGraph()
>>> DG.add_weighted_edges_from([(1,2,0.5), (3,1,0.75)])
>>> DG.out_degree(1,weight='weight')
0.5
>>> DG.degree(1,weight='weight')
1.25
>>> DG.successors(1)
[2]
>>> DG.neighbors(1)
[2]
Some algorithms work only for directed graphs and others are not well defined for directed graphs. Indeed the tendency to lump directed and undirected graphs together is dangerous. If you want to treat a directed graph as undirected for some measurement you should probably convert it using Graph.to_undirected() or with

>>> H = nx.Graph(G) # convert G to undirected graph
Multigraphs
NetworkX provides classes for graphs which allow multiple edges between any pair of nodes. The MultiGraph and MultiDiGraph classes allow you to add the same edge twice, possibly with different edge data. This can be powerful for some applications, but many algorithms are not well defined on such graphs. Shortest path is one example. Where results are well defined, e.g. MultiGraph.degree() we provide the function. Otherwise you should convert to a standard graph in a way that makes the measurement well defined.

>>> MG=nx.MultiGraph()
>>> MG.add_weighted_edges_from([(1,2,.5), (1,2,.75), (2,3,.5)])
>>> MG.degree(weight='weight')
{1: 1.25, 2: 1.75, 3: 0.5}
>>> GG=nx.Graph()
>>> for n,nbrs in MG.adjacency_iter():
...    for nbr,edict in nbrs.items():
...        minvalue=min([d['weight'] for d in edict.values()])
...        GG.add_edge(n,nbr, weight = minvalue)
...
>>> nx.shortest_path(GG,1,3)
[1, 2, 3]
Graph generators and graph operations
In addition to constructing graphs node-by-node or edge-by-edge, they can also be generated by

Applying classic graph operations, such as:

subgraph(G, nbunch)      - induce subgraph of G on nodes in nbunch
union(G1,G2)             - graph union
disjoint_union(G1,G2)    - graph union assuming all nodes are different
cartesian_product(G1,G2) - return Cartesian product graph
compose(G1,G2)           - combine graphs identifying nodes common to both
complement(G)            - graph complement
create_empty_copy(G)     - return an empty copy of the same graph class
convert_to_undirected(G) - return an undirected representation of G
convert_to_directed(G)   - return a directed representation of G
Using a call to one of the classic small graphs, e.g.
>>> petersen=nx.petersen_graph()
>>> tutte=nx.tutte_graph()
>>> maze=nx.sedgewick_maze_graph()
>>> tet=nx.tetrahedral_graph()
Using a (constructive) generator for a classic graph, e.g.
>>> K_5=nx.complete_graph(5)
>>> K_3_5=nx.complete_bipartite_graph(3,5)
>>> barbell=nx.barbell_graph(10,10)
>>> lollipop=nx.lollipop_graph(10,20)
Using a stochastic graph generator, e.g.
>>> er=nx.erdos_renyi_graph(100,0.15)
>>> ws=nx.watts_strogatz_graph(30,3,0.1)
>>> ba=nx.barabasi_albert_graph(100,5)
>>> red=nx.random_lobster(100,0.9,0.9)
Reading a graph stored in a file using common graph formats, such as edge lists, adjacency lists, GML, GraphML, pickle, LEDA and others.
>>> nx.write_gml(red,"path.to.file")
>>> mygraph=nx.read_gml("path.to.file")
Details on graph formats: Reading and writing graphs

Details on graph generator functions: Graph generators

Analyzing graphs
The structure of G can be analyzed using various graph-theoretic functions such as:

# 分析图

```
>>> G=nx.Graph()
>>> G.add_edges_from([(1,2),(1,3)])
>>> G.add_node("spam")       # adds node "spam"
>>> nx.connected_components(G)
[[1, 2, 3], ['spam']]
>>> sorted(nx.degree(G).values())
[0, 1, 1, 2]
>>> nx.clustering(G)
{1: 0.0, 2: 0.0, 3: 0.0, 'spam': 0.0}
```
Functions that return node properties return dictionaries keyed by node label.

>>> nx.degree(G)
{1: 2, 2: 1, 3: 1, 'spam': 0}
For values of specific nodes, you can provide a single node or an nbunch of nodes as argument. If a single node is specified, then a single value is returned. If an nbunch is specified, then the function will return a dictionary.

>>> nx.degree(G,1)
2
>>> G.degree(1)
2
>>> G.degree([1,2])
{1: 2, 2: 1}
>>> sorted(G.degree([1,2]).values())
[1, 2]
>>> sorted(G.degree().values())
[0, 1, 1, 2]
Details on graph algorithms supported: Algorithms


Drawing graphs
NetworkX is not primarily a graph drawing package but basic drawing with Matplotlib as well as an interface to use the open source Graphviz software package are included. These are part of the networkx.drawing package and will be imported if possible. See Drawing for details.

# 绘图

Note that the drawing package in NetworkX is not yet compatible with Python versions 3.0 and above.

First import Matplotlib’s plot interface (pylab works too)

>>> import matplotlib.pyplot as plt
You may find it useful to interactively test code using “ipython -pylab”, which combines the power of ipython and matplotlib and provides a convenient interactive mode.

To test if the import of networkx.drawing was successful draw G using one of

>>> nx.draw(G)
>>> nx.draw_random(G)
>>> nx.draw_circular(G)
>>> nx.draw_spectral(G)
when drawing to an interactive display. Note that you may need to issue a Matplotlib

>>> plt.show()
command if you are not using matplotlib in interactive mode: (See Matplotlib FAQ )

To save drawings to a file, use, for example

>>> nx.draw(G)
>>> plt.savefig("path.png")
writes to the file “path.png” in the local directory. If Graphviz and PyGraphviz, or pydotplus, are available on your system, you can also use

>>> from networkx.drawing.nx_pydot import write_dot
>>> nx.draw_graphviz(G)
>>> write_dot(G,'file.dot')
Details on drawing graphs: Drawing