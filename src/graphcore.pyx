
cimport cmdb

from graph import Node, Edge, decode_edge

cdef enum:
    MAP_SIZE = 1024 * 1024 * 1024 * 20
    MAX_DBS = 3


cdef class EdgeSet:
    cdef Graph graph

    def __init__(self, graph):
        self.graph = graph


cdef class NodeSet:
    cdef Graph graph

    def __init__(self, graph):
        self.graph = graph


cdef class Graph:
    cdef cmdb.MDB_env *env
    cdef cmdb.MDB_dbi *nodes_db
    cdef cmdb.MDB_dbi *edges_db
    cdef cmdb.MDB_dbi *meta_db

    cdef NodeSet _nodes
    cdef EdgeSet _edges


    property nodes:
        def __get__(self):
            return self._nodes


    property edges:
        def __get__(self):
            return self._edges


    def __init__(self):
        cdef cmdb.MDB_txn *txn

        self._nodes = NodeSet(self)
        self._edges = EdgeSet(self)

        cmdb.mdb_env_create(&self.env)
        cmdb.mdb_env_set_mapsize(self.env, MAP_SIZE)
        cmdb.mdb_env_set_maxdbs(self.env, MAX_DBS)

        cmdb.mdb_env_open(self.env, "temp", cmdb.MDB_NOSUBDIR, 0664)

        cmdb.mdb_txn_begin(self.env, NULL, 0, &txn)

        cmdb.mdb_dbi_open(txn, "nodes", 0, self.nodes_db)
        cmdb.mdb_dbi_open(txn, "edges", 0, self.edges_db) 
        cmdb.mdb_dbi_open(txn, "meta", 0, self.meta_db)

        cmdb.mdb_txn_commit(txn)




g = Graph()


