import os, csv
import scipy
from scipy import io
from sklearn.feature_extraction.text import TfidfVectorizer
import sys
reload(sys)
sys.setdefaultencoding("ISO-8859-1")

corpus = []
file_labels = {}
label_filenm = "webkb_labels.txt"
vec_filenm = "webkb_vectors.mtx"
"""
Creates tab-delimited file with <filename> <cat1 indicator>  .. <cat4 indicator>
"""
def prep(cd):
    print("..opening category {c}".format(c=cd) )
    for path, subdirs, files in os.walk(cd):
        for f in files:
            file_labels[f] = cd
            corpus.append(open(os.path.join(path,f), 'r').read().encode('utf-8').strip())
            ls = ["0","0","0","0"]
            ls[category_dirs.index(cd)] = "1"
            ls = "\t".join(ls)
            label_file.write("{f}\t{l}\n".format(f=f, l=ls))

def tfidf():
    tf = TfidfVectorizer(analyzer='word', min_df = 1, stop_words = 'english')
    tfidf_matrix =  tf.fit_transform(corpus)
    io.mmwrite(vec_file, tfidf_matrix)

if __name__=="__main__":
    webkb_dir = "/datasets/webkb"
    output_dir = "../../test/data"
    label_file = open(os.path.join(output_dir, label_filenm), 'w')
    vec_file = open(os.path.join(output_dir, vec_filenm), 'w')

    category_dirs = ["{d}/course", "{d}/department", "{d}/faculty", "{d}/project"]
    category_dirs = [x.format(d=webkb_dir) for x in category_dirs]

    print("Looking for WebKB data in {d}".format(d=webkb_dir))
    for cd in category_dirs:
        prep(cd.format(d=webkb_dir))
    label_file.close()
    tfidf()
    vec_file.close()
