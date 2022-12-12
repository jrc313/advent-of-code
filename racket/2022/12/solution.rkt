#lang racket

(require racket/struct)
(require (only-in srfi/13 string-contains))
(require graph)

(define test-mode (make-parameter #f))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              #:args () (void))

(struct point (x y)
    #:transparent
    #:mutable
    #:methods gen:custom-write
    [(define write-proc
        (make-constructor-style-printer (λ (p) 'point) (λ (p) (list (point-x p) (point-y p)))))])

(define (point+ p1 p2) (point (+ (point-x p1) (point-x p2)) (+ (point-y p1) (point-y p2))))

(define point-offsets (map (λ (p) (point (car p) (cadr p)))
    (filter-not (λ (p) (and (= 0 (car p))
                            (= 0 (cadr p))))
        (cartesian-product '(-1 0 1) '(-1 0 1)))))

(define point-offsets-no-corners (filter (λ (p) (or (= 0 (point-x p)) (= 0 (point-y p)))) point-offsets))

(define (number-between? n a b) (and (>= n a) (<= n b)))

(define (input->char-matrix input [replacements (hash)])
    (map (λ (row)
        (map (λ (c) (- (if (hash-has-key? replacements c)
                           (char->integer (hash-ref replacements c))
                           (char->integer c))
                        (char->integer #\a)))
            (string->list row)))
        input))

(define (matrix-value-at matrix pos) (list-ref (list-ref matrix (point-x pos)) (point-y pos)))

(define (point->symbol p)
    (string->symbol (string-join (list (number->string (point-x p)) (number->string (point-y p))) ".")))

(define (make-edge a b)
    (list a b))

(define (cell-neighbours matrix pos [corners? #f] [offsets (if corners? point-offsets point-offsets-no-corners)])
    (let ([matrix-rows (length matrix)]
          [matrix-cols (length (car matrix))])
        (map (λ (cell-ref) (cons cell-ref (matrix-value-at matrix cell-ref)))
        (filter-not (λ (p) (or (< (point-x p) 0) (< (point-y p) 0)
                               (>= (point-x p) matrix-rows) (>= (point-y p) matrix-cols)))
            (map (λ (p) (point+ pos p)) offsets)))))

(define (matrix->edge-list matrix valid-move? [edges '()])
    (for* ([rownum (length matrix)] [colnum (length (car matrix))])
        (let* ([cell (point rownum colnum)] [cell-value (matrix-value-at matrix cell)])
            (set! edges (append edges
                (map (λ (neighbour) (make-edge cell (car neighbour)))
                    (filter (λ (neighbour) (valid-move? cell-value (cdr neighbour)))
                            (cell-neighbours matrix cell)))))))

    edges)

(define (find-in-string-list lst s [pos #f])
    (let ([new-lst 
        (for ([rownum (length lst)]
                   [row lst])
            (let ([colnum (string-contains row s)])
                (when colnum (set! pos (point rownum colnum)))))])
        pos))

(define (make-move-validator low high)
    (λ (current neighbour)
        (number-between? (- neighbour current) low high)))

(define (input-parser input)
    (list (find-in-string-list input "S") (find-in-string-list input "E") input))

(define (part1 input)
    (let* ([start (car input)]
           [end (cadr input)]
           [grid (input->char-matrix (caddr input) (hash #\S #\a #\E #\z))]
           [matrix (matrix->edge-list
                        grid
                        (make-move-validator -27 1))]
           [graph (directed-graph matrix)])

        (define-values (distances paths) (dijkstra graph start))
        (hash-ref distances end)))

(define (part2 input)
    (let* ([start (car input)]
           [end (cadr input)]
           [grid (input->char-matrix (caddr input) (hash #\S #\a #\E #\z))]
           [matrix (matrix->edge-list
                        grid
                        (make-move-validator -1 27))]
           [graph (directed-graph matrix)])

        (define-values (distances paths) (dijkstra graph end))
        (foldl (λ (p min)
            (let ([val (matrix-value-at grid p)]
                  [distance (hash-ref distances p)])
                (if (and (= 0 val)
                         (< distance min)) distance min)))
            +inf.0 (hash-keys distances))))


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