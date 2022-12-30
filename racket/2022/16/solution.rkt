#lang racket

(require racket/struct)
(require graph)
(require memo)

(define test-mode (make-parameter #t))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              [("-p" "--puzzle") "Run in puzzle mode" (test-mode #f)]
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

(define (print-tunnel-graph g valve-hash)
  (define-vertex-property g label #:init (string-append $v ":" (number->string (valve-flow-rate (hash-ref valve-hash $v)))))
  (graphviz g #:vertex-attributes (list (list 'label label))))

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

(define (path-keys path [exclude-key "AA"])
  (for/set ([p path]
            #:do [(define k (path-item-key p))]
            #:when (not (string=? k exclude-key)))
    k))

(define (distinct-sets? a b)
  (define path-intersect (set-intersect a b))
  (= (set-count path-intersect) 0))

(define (best-two-distinct lst)
  (for*/fold ([max-pressure 0])
             ([a lst]
              [b lst]
              #:do [(define p (+ (car a) (car b)))]
              #:when (and (> p max-pressure) (distinct-sets? (cdr a) (cdr b))))
    (max p max-pressure)))

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
      (set! tested-paths (cons (cons pressure (path-keys next-path)) tested-paths)))

    (when (> pressure max-pressure)
      (set! max-pressure pressure)
      (set! max-pressure-path next-path))

    (for ([neighbour (get-neighbors tunnel-graph current-valve)]
          #:when (and (not (path-has-item? next-path neighbour))
                      (<= (+ next-time (weight current-valve neighbour)) max-minutes)))
      (navigate-cave neighbour next-time next-path)))

  (navigate-cave start)

  (cond [find-two?
         (define sorted-paths (sort tested-paths (λ (a b) (> (car a) (car b)))))
         (best-two-distinct sorted-paths)]
        [else max-pressure]))


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