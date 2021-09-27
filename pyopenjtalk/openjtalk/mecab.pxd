# distutils: language = c++

cdef extern from "mecab.h":
    cdef cppclass Mecab:
        char **feature
        int size
        void *model
        void *tagger
        void *lattice

    cdef int Mecab_initialize(Mecab *m)
    cdef int Mecab_load(Mecab *m, const char *dicdir)
    cdef int Mecab_analysis(Mecab *m, const char *str)
    cdef int Mecab_print(Mecab *m)
    int Mecab_get_size(Mecab *m)
    char **Mecab_get_feature(Mecab *m)
    cdef int Mecab_refresh(Mecab *m)
    cdef int Mecab_clear(Mecab *m)
    cdef int mecab_dict_index(int argc, char **argv)

cdef extern from "mecab.h" namespace "MeCab":
    cdef cppclass Tagger:
        pass
    cdef cppclass Lattice:
        pass
    cdef cppclass Model:
        Tagger *createTagger()
        Lattice *createLattice()
    cdef Model *createModel(int argc, char **argv)

from libc.string cimport strlen
cdef inline int Mecab_load_ex(Mecab *m, char* dicdir, char* userdir):
    if m == NULL:
        return 0
    if dicdir == NULL:
        return 0
    if userdir == NULL:
        return 0

    if strlen(userdir) == 0:
        return Mecab_load(m, dicdir)

    Mecab_clear(m)

    cdef char *argv[5]
    argv[0] = "mecab"
    argv[1] = "-d"
    argv[2] = dicdir
    argv[3] = "-u"
    argv[4] = userdir
    cdef Model *model = createModel(5, argv)

    if model == NULL:
        return 0
    m.model = model

    cdef Tagger *tagger = model.createTagger()
    if tagger == NULL:
        Mecab_clear(m)
        return 0
    m.tagger = tagger

    cdef Lattice *lattice = model.createLattice()
    if lattice == NULL:
        Mecab_clear(m)
        return 0
    m.lattice = lattice
    return 1
