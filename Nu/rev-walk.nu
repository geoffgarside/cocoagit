#!/usr/bin/env nush

;; command-line input
(set exit (NuBridgedFunction functionWithName:"exit" signature:"vi"))

(set argv ((NSProcessInfo processInfo) arguments))

(set path (argv lastObject))

(load "Git")
(import Foundation)

(set repo ((GITRepo alloc) initWithRoot:path))
(set graph ((GITGraph alloc) init))
(graph buildGraphWithStartingCommit:(repo head))

(NSLog "finished building graph")
;
; (set start (revEnum start))

; http://www.ics.uci.edu/~eppstein/161/960208.html#topo
; list K = empty
; list L = empty
; for each vertex v in G
; let I[v] = number of incoming edges to v
; if (I[v] = 0) add v to K
; while (G is not empty)
; remove a vertex v from K
; for each outgoing edge (v,w)
; decrement I[w]
; if (I[w] = 0) add w to K
; add v to L

; python example:
; http://www.bitformation.com/art/python_toposort.html

; As is, this function seems to produce the same order of commits as:
; git rev-list --topo-order HEAD
; Also.. since building the tree is the slow step, this is not
; doing the sort in Nu does not make a big difference
; g is a dictionary of nodes (GITNodes in this case)
(function topological_sort (g)
     (set roots (NSMutableArray arrayWithCapacity:(g count)))
     (set sorted (NSMutableArray arrayWithCapacity:(g count)))
     
     (set my_g (g mutableCopy))
     ((my_g copy)
      each:
      (do (k v)
          (set indegree (v indegree))
          (if (eq 0 indegree)
              (roots << v)
              (my_g removeObjectForKey:k))))
     
     (while (> (roots count) 0)
            ; use LIFO order for selecting next root
            (set v (roots lastObject))
            (roots removeLastObject)
            (sorted addObject:v)
            
            ((v outNodes) each:
                 (do (w)
                     (w decrementIndegree)
                     (if (eq 0 (w indegree))
                         (roots addObject:w))))
            (my_g removeObjectForKey:((v object) sha1))) ; really slooowwww on an array
     sorted)

; Nu
(set nodes (topological_sort (graph rawNodes)))
; objc
;(set nodes (graph nodesSortedByTopology:YES))

(NSLog "sorted commits: #{(nodes count)} commits")


; (commits each: (do (node)
;                    (set c (node object))
;                    (set nr ((c message) rangeOfCharacterFromSet:(NSCharacterSet newlineCharacterSet)))
;                    (if (eq NSNotFound (nr 0)) (set nr (list ((c message) length) 0)))
;                    (set r (list 0 (nr 0)))
;                    ;(puts "#{((c sha1) substringToIndex:8)} #{((c message) substringWithRange:r)}")
;                    (puts "#{((c sha1) substringToIndex:8)}")))
