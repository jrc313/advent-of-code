#lang racket

(require racket/struct)

(define test-mode (make-parameter #t))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              [("-p" "--puzzle") "Run in puzzle mode" (test-mode #f)]
              #:args () (void))

(struct point (x y)
  #:transparent
  #:mutable
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (p) 'point)
      (lambda (p) (list (point-x p) (point-y p)))))])

(define (point- p1 p2)
  (point (- (point-x p1) (point-x p2))
         (- (point-y p1) (point-y p2))))

(define (point+ p1 p2)
  (point (+ (point-x p1) (point-x p2))
         (+ (point-y p1) (point-y p2))))

(define (point=? p1 p2)
  (and (= (point-x p1) (point-x p2))
       (= (point-y p1) (point-y p2))))

(define (make-vectrix rows cols v)
  (for/vector ([row (in-range rows)])
    (make-vector cols v)))

(define (vectrix-ref vec pos)
  (vector-ref (vector-ref vec (point-y pos))
              (point-x pos)))

(define (vectrix-set! vec pos v)
  (vector-set! (vector-ref vec (point-y pos))
               (point-x pos) v))

(define (extend-vectrix vec v [rows 1] [above? #t])
  (cond [(< rows 1) vec]
        [else
         (define extension (make-vectrix rows (vector-length (vector-ref vec 0)) v))
         (cond [above? (vector-append extension vec)]
               [else (vector-append vec extension)])]))

(define (vectrix-apply vec start-pos end-pos proc)
  (for ([row vec]
        [y (in-range (point-y start-pos) (point-y end-pos))]
        #:when #t
        [cell-value row]
        [x (in-range (point-x start-pos) (point-x end-pos))])
    (proc x y cell-value)))

(define (vectrix+! vec overlay pos [value-proc (λ (a b) (or a b))])
  (define pos-x (point-x pos))
  (define pos-y (point-y pos))
  (define w (vector-length (vector-ref overlay 0)))
  (define h (vector-length overlay))
  (vectrix-apply overlay (point 0 0) (point w h)
                 (λ (x y v)
                   (define vec-pos (point (+ pos-x x) (+ pos-y y)))
                   (define vec-value (vectrix-ref vec vec-pos))
                   (vectrix-set! vec vec-pos (value-proc vec-value v)))))

(define (vectrix=? a b)
  (for/and ([arow a]
            [brow b]
            #:when #t
            [aval arow]
            [bval brow])
    (equal? aval bval)))

(define (display-chamber chamber)
  (for ([row chamber])
    (for ([cell-value row])
      (display (if cell-value
                   (vector-ref rock-display-vector cell-value)
                   "⬜️")))
    (display "\n")))

(define (rock-string->vectrix s v)
  (define lines (string-split s "\n"))
  (define rows (length lines))
  (define cols (string-length (car lines)))
  (define vec (make-vectrix rows cols #f))
  (for ([y (in-range rows)]
        [line lines]
        #:when #t
        [x (in-range cols)]
        [c (string->list line)])
    (when (char=? c #\#)
      (vectrix-set! vec (point x y) v)))
  vec)

(define rock-display-vector (vector "🟥" "🟨" "🟦" "🟧" "🟪"))

(define rock-vector (vector (rock-string->vectrix "####" 0)
                            (rock-string->vectrix ".#.\n###\n.#." 1)
                            (rock-string->vectrix "..#\n..#\n###" 2)
                            (rock-string->vectrix "#\n#\n#\n#" 3)
                            (rock-string->vectrix "##\n##" 4)))

(define move-left (point -1 0))
(define move-right (point 1 0))
(define move-down (point 0 1))

(define (rock-dimensions rock)
  (values (vector-length rock) (vector-length (vector-ref rock 0))))

(define (empty-rows-at-top-of-chamber chamber)
  (for/fold ([empty-rows 0])
            ([row chamber])
    #:break (for/or ([cell row]) cell)
    (+ empty-rows 1)))

(define (add-next-rock rock-count prev-chamber chamber-width new-rock-offset-x new-rock-offset-y)
  (define rock (vector-ref rock-vector (modulo (- rock-count 1) (vector-length rock-vector))))
  (define-values (rock-height rock-width) (rock-dimensions rock))
  (define space-required (+ new-rock-offset-y rock-height))
  (define new-rock-pos (point new-rock-offset-x 0))
  (define chamber (cond [(null? prev-chamber)
                         (make-vectrix space-required chamber-width #f)]
                        [else
                         (define empty-rows (empty-rows-at-top-of-chamber prev-chamber))
                         (cond [(< empty-rows space-required)
                                (extend-vectrix prev-chamber #f (- space-required empty-rows))]
                               [else
                                (set! new-rock-pos (point new-rock-offset-x (- empty-rows space-required)))
                                prev-chamber])]))
  (values rock chamber rock-width rock-height new-rock-pos))

(define (rock-can-move? rock pos width height move chamber)
  (define new-pos (point+ pos move))
  (define new-pos-x (point-x new-pos))
  (define new-pos-y (point-y new-pos))
  (define extent-x (- (+ new-pos-x width) 1))
  (define extent-y (- (+ new-pos-y height) 1))
  (define chamber-max-x (- (vector-length (vector-ref chamber 0)) 1))
  (define chamber-max-y (- (vector-length chamber) 1))
  (cond [(< new-pos-x 0) #f]
        [(< new-pos-y 0) #f]
        [(> extent-x chamber-max-x) #f]
        [(> extent-y chamber-max-y) #f]
        [else (for/and ([row rock]
                        [y (in-range new-pos-y (+ extent-y 1))]
                        #:when #t
                        [cell-value row]
                        [x (in-range new-pos-x (+ extent-x 1))])
                (nand cell-value (vectrix-ref chamber (point x y))))]))

(define (chamber-height chamber)
  (- (vector-length chamber) (empty-rows-at-top-of-chamber chamber)))

(define (simulate-chamber wind-list
                          #:rocks-to-fall [rocks-to-fall 2022]
                          #:chamber-width [chamber-width 7]
                          #:new-rock-offset-x [new-rock-offset-x 2]
                          #:new-rock-offset-y [new-rock-offset-y 3])

  (define total-wind (length wind-list))
  (define total-rocks (vector-length rock-vector))
  (define rock-count 1)
  (define-values (rock chamber rock-width rock-height rock-pos)
    (add-next-rock 1 null chamber-width new-rock-offset-x new-rock-offset-y))
  (define rock-wind-hash (make-hash))

  (define cycle-identified? #f)
  (define calculated-cycle-height 0)
  (define remainder-rocks +inf.0)

  (for ([i (in-naturals)]
        [wind-dir (in-cycle wind-list)]
        #:do [(define wind-num (modulo i total-wind))
              (define rock-num (modulo rock-count total-rocks))]
        #:break (or (<= remainder-rocks 0) (> rock-count rocks-to-fall)))
    (when (rock-can-move? rock rock-pos rock-width rock-height wind-dir chamber)
      (set! rock-pos (point+ rock-pos wind-dir)))

    (cond [(rock-can-move? rock rock-pos rock-width rock-height move-down chamber)
           (set! rock-pos (point+ rock-pos move-down))]
          [else (vectrix+! chamber rock rock-pos)
                (set! rock-count (+ rock-count 1))
                (set!-values (rock chamber rock-width rock-height rock-pos)
                             (add-next-rock rock-count chamber chamber-width new-rock-offset-x new-rock-offset-y))
                (define current-height (chamber-height chamber))
                #;(when (= rock-count 20) (display-chamber chamber) (display "\n"))

                (when cycle-identified?
                  (set! remainder-rocks (- remainder-rocks 1)))

                (when (and (> i total-wind) (not cycle-identified?))
                  (define rock-wind-key (cons wind-num rock-num))
                  (define rock-wind-val (cons (- rock-count 1) current-height))

                  (when (hash-has-key? rock-wind-hash rock-wind-key)
                    (set! cycle-identified? #t)
                    (define prev-rock-wind (hash-ref rock-wind-hash rock-wind-key))
                    (define rocks-in-cycle (- (car rock-wind-val) (car prev-rock-wind)))
                    (define height-in-cycle (- (cdr rock-wind-val) (cdr prev-rock-wind)))
                    (define rocks-remaining (- rocks-to-fall (car rock-wind-val)))
                    (define cycles-remaining (floor (/ rocks-remaining rocks-in-cycle)))
                    (define rocks-added-in-remaining-cycles (* rocks-in-cycle cycles-remaining))
                    (set! calculated-cycle-height (* height-in-cycle cycles-remaining))
                    (set! remainder-rocks (- rocks-remaining rocks-added-in-remaining-cycles)))
                  
                  (hash-set! rock-wind-hash rock-wind-key rock-wind-val))]))

  (+ calculated-cycle-height (chamber-height chamber)))

(define (input-parser input)
  (for/list ([wind-dir (string->list (car input))])
    (cond [(char=? wind-dir #\<) move-left]
          [else move-right])))

(define (part1 input)
  (simulate-chamber input #:rocks-to-fall 2022))

(define (part2 input)
  (simulate-chamber input #:rocks-to-fall 1000000000000))


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