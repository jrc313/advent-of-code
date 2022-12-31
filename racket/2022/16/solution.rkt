#lang racket

(require racket/struct)
(require graph)
(require memo)

(define test-mode (make-parameter #t))
(define full-graph (make-parameter #f))
(define hide-unused-paths (make-parameter #f))

(command-line #:usage-help "Run the AOC script"
              #:once-each
              [("-t" "--test") "Run in test mode" (test-mode #t)]
              [("-p" "--puzzle") "Run in puzzle mode" (test-mode #f)]
              [("-f" "--fullgraph") "Do not prune unused paths from output graph" (full-graph #t)]
              [("-i" "--invis") "Make unused paths invisible" (hide-unused-paths #t)]
              #:args () (void))

(struct valve (key flow-rate neighbours)
  #:transparent
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (v) 'v)
      (lambda (v) (list (valve-key v) (valve-flow-rate v) (valve-neighbours v)))))])

(struct cave (valve-hash tunnel-graph)
  #:transparent
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (c) 'c)
      (lambda (c) (list (cave-valve-hash c)
                        (print-tunnel-graph (cave-tunnel-graph c)
                                            (cave-valve-hash c))))))])

(struct path-item (key dist flow)
  #:transparent
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (pi) 'pi)
      (lambda (pi) (list (path-item-key pi) (path-item-dist pi) (path-item-flow pi)))))])

(struct tested-path (pressure keys path))

(define (print-tunnel-graph g valve-hash #:vertex-attrs [vertex-attrs '()] #:edge-attrs [edge-attrs '()])
  (define-vertex-property g label #:init (string-append $v " : " (number->string (valve-flow-rate (hash-ref valve-hash $v)))))
  (graphviz g
            #:vertex-attributes (append (list (list 'label label)) vertex-attrs)
            #:edge-attributes edge-attrs))

(define (edge-in-set? st u v )
  (or (set-member? st (cons u v))
      (set-member? st (cons v u))))

(define (print-tunnel-graph-with-path tunnel-graph valve-hash path-a [path-b '()])
  (define path-a-keys (path-keys path-a ""))
  (define path-b-keys (path-keys path-b ""))
  (define path-a-edges (path-item-list->edge-set (reverse path-a)))
  (define path-b-edges (path-item-list->edge-set (reverse path-b)))
  (define both-path-edges (cond [(empty? path-b) path-a-edges]
                                [else (set-union path-a-edges path-b-edges)]))

  (define g (cond [(full-graph) tunnel-graph]
                  [else
                   (define pruned-edges (for/list ([vertex-list (get-edges tunnel-graph)]
                                                   #:do [(define u (car vertex-list))
                                                         (define v (cadr vertex-list))
                                                         (define edge (cons u v))]
                                                   #:when (or (set-member? path-a-edges edge)
                                                              (set-member? path-b-edges edge)))
                                          (list (edge-weight tunnel-graph u v) u v)))
                   (weighted-graph/undirected pruned-edges)]))


  (define-vertex-property
    g valve-fill-colour
    #:init (cond [(set-member? path-a-keys $v) "coral"]
                 [(set-member? path-b-keys $v) "cornflowerblue"]
                 [else "gainsboro"]))
  (define-vertex-property
    g valve-font-colour
    #:init (cond [(set-member? path-a-keys $v) "white"]
                 [(set-member? path-b-keys $v) "white"]
                 [else "antiquewhite4"]))
  (define-vertex-property g valve-style #:init "filled")
  (define-edge-property
    g path-colour
    #:init (cond [(edge-in-set? path-a-edges $from $to) "coral"]
                 [(edge-in-set? path-b-edges $from $to) "cornflowerblue"]
                 [else "gainsboro"]))
  (define-edge-property
    g path-style
    #:init (cond [(edge-in-set? both-path-edges $from $to) ""]
                 [(hide-unused-paths) "invis"]
                 [else ""]))

  (define vertex-attrs (list (list 'fillcolor valve-fill-colour)
                             (list 'color valve-fill-colour)
                             (list 'fontcolor valve-font-colour)
                             (list 'style valve-style)))
  (define edge-attrs (list (list 'color path-colour)
                           (list 'style path-style)))

  (print-tunnel-graph g valve-hash #:vertex-attrs vertex-attrs #:edge-attrs edge-attrs))

(define (write-to-file filename str)
  (define out (open-output-file filename #:exists 'truncate))
  (display str out)
  (close-output-port out))

(define (lines->valve-hash lines)
  (for/hash ([line lines])
    (let* ([pattern #rx"^Valve ([A-Z]+) has flow rate=([0-9]+); tunnels? leads? to valves? ([A-Z, ]+)$"]
           [m (regexp-match pattern line)]
           [key (second m)]
           [flow-rate (string->number (third m))]
           [neighbours (string-split (fourth m) ", ")])
      (values key (valve key flow-rate neighbours)))))

(define (valve-hash->edge-list valve-hash)
  (for*/list ([valve (hash-values valve-hash)]
              [neighbour (valve-neighbours valve)])
    (list (valve-key valve) neighbour)))

(define (filter-zero-flow-valves valve-hash [start-valve "AA"])
  (for/hash ([valve (hash-values valve-hash)]
             #:when (or (> (valve-flow-rate valve) 0) (string=? (valve-key valve) start-valve)))
    (values (valve-key valve) valve)))

(define (valve-edges->fully-connected-graph valve-hash edges)
  (define flow-valve-hash (filter-zero-flow-valves valve-hash))
  (define tunnel-graph (unweighted-graph/undirected edges))
  (define shortest-path-list
    (for/list ([valve (hash-values flow-valve-hash)]
               #:do [(define key (valve-key valve))
                     (define-values (distance-hash path-hash) (dijkstra tunnel-graph key))]
               [(neighbour distance) distance-hash]
               #:when (and (> distance 0) (hash-has-key? flow-valve-hash neighbour)))
      (list (+ 1 distance) key neighbour)))
  (values flow-valve-hash (weighted-graph/undirected shortest-path-list)))

(define (input-parser input)
  (define valve-hash (lines->valve-hash input))
  (define edges (valve-hash->edge-list valve-hash))
  (define-values (flow-valve-hash tunnel-graph) (valve-edges->fully-connected-graph valve-hash edges))
  (cave flow-valve-hash tunnel-graph))

(define/memoize (sum-pressure flow-list max-minutes)
  (define-values
    (pressure total-time)
    (for/fold ([pressure 0]
               [current-time 0])
              ([flow-item (reverse flow-list)])
      (define flow (path-item-flow flow-item))
      (define next-time (+ current-time (path-item-dist flow-item)))
      (define next-pressure (+ pressure (* flow (- max-minutes next-time))))
      (values next-pressure
              next-time)))
  pressure)

(define (path-has-item? path item)
  (for/or ([path-item path])
    (string=? (path-item-key path-item) item)))

(define (path-item-list->edge-set path)
  (cond [(< (length path) 2) '()]
        [else (for/set ([a path]
                        [b (cdr path)])
                (cons (path-item-key a) (path-item-key b)))]))

(define (path-keys path [exclude-key "AA"])
  (for/set ([p path]
            #:do [(define k (path-item-key p))]
            #:when (not (string=? k exclude-key)))
    k))

(define (distinct-sets? a b)
  (define path-intersect (set-intersect a b))
  (= (set-count path-intersect) 0))

(define (best-two-distinct lst)
  (for*/fold ([max-pressure 0] [max-path-a '()] [max-path-b '()])
             ([a lst]
              [b lst]
              #:do [(define next-pressure (+ (tested-path-pressure a)
                                             (tested-path-pressure b)))]
              #:when (and (> next-pressure max-pressure)
                          (distinct-sets? (tested-path-keys a)
                                          (tested-path-keys b))))
    (cond [(> next-pressure max-pressure)
           (values next-pressure (tested-path-path a) (tested-path-path b))]
          [else (values max-pressure max-path-a max-path-b)])))

(define (optimal-path-in-max-minutes cave [start "AA"] [max-minutes 30] [find-two? #f])
  (define valve-hash (cave-valve-hash cave))
  (define tunnel-graph (cave-tunnel-graph cave))
  (define valve-count (hash-count valve-hash))
  (define weight (λ (u v) (edge-weight tunnel-graph u v)))
  (define-vertex-property tunnel-graph flow-rate #:init (valve-flow-rate (hash-ref valve-hash $v)))

  (define max-pressure 0)
  (define max-pressure-path '())
  (define tested-paths '())

  (define (navigate-cave current-valve [current-time 1] [path '()])
    (define dist (if (empty? path) 0 (weight current-valve (path-item-key (car path)))))
    (define flow (flow-rate current-valve))
    (define next-time (+ current-time dist))
    (define next-path (cons (path-item current-valve dist flow) path))

    (define pressure (sum-pressure next-path max-minutes))

    (when (> (length next-path) 1)
      (set! tested-paths (cons (tested-path pressure (path-keys next-path) next-path) tested-paths)))

    (when (> pressure max-pressure)
      (set! max-pressure pressure)
      (set! max-pressure-path next-path))

    (for ([neighbour (get-neighbors tunnel-graph current-valve)]
          #:when (and (not (path-has-item? next-path neighbour))
                      (<= (+ next-time (weight current-valve neighbour)) max-minutes)))
      (navigate-cave neighbour next-time next-path)))

  (navigate-cave start)

  (cond [find-two?
         (define half-valve-count (ceiling (/ valve-count 2)))
         (define paths-of-appropriate-length
           (for/list ([path tested-paths]
                      #:do [(define path-length (length (tested-path-path path)))]
                      #:when (and (<= path-length half-valve-count)
                                  (>= path-length (- half-valve-count 1))))
             path))
         (define sorted-paths
           (sort paths-of-appropriate-length
                 (λ (a b) (>
                           (tested-path-pressure a)
                           (tested-path-pressure b)))))
         (define-values (pressure best-path-a best-path-b) (best-two-distinct sorted-paths))
         (write-to-file "part2.dot" (print-tunnel-graph-with-path tunnel-graph valve-hash best-path-a best-path-b))
         pressure]
        [else
         (write-to-file "part1.dot" (print-tunnel-graph-with-path tunnel-graph valve-hash max-pressure-path))
         max-pressure]))


(define (part1 the-cave)
  (optimal-path-in-max-minutes the-cave))

(define (part2 the-cave)
  (optimal-path-in-max-minutes the-cave "AA" 26 #t))

(define (load-input path)
  (file->lines path))

(define (parse-input input-parser input)
  (define-values (result cpu real gc) (time-apply input-parser (list input)))
  (printf "🧹 Parse input: ~ams\n" cpu)
  (values (car result) cpu))

(define (run-part n proc input)
  (define-values (result cpu real gc) (time-apply proc (list input)))
  (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
  cpu)

(define raw-input (load-input (if (test-mode) "test.txt" "input.txt")))
(define-values (parsed-input parse-time) (parse-input input-parser raw-input))
(define part-times
  (list (run-part 1 part1 parsed-input)
        (run-part 2 part2 parsed-input)))

(printf "\n")
(printf "⌛️ Total time: ~ams\n" (+ parse-time (apply + part-times)))