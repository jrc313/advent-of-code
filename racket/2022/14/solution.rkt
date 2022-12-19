#lang racket

(require racket/struct
         2htdp/image)

(define test-mode (make-parameter #f))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              #:args () (void))


(define space 0)
(define rock 1)
(define sand 2)
(define highlight 3)

(define cave-print-chars (vector "⬜️" "⬛️" "🟠" "🔴"))

(struct cave (pour-col vectrix)
    #:transparent
    #:mutable
    #:methods gen:custom-write
    [(define write-proc
        (make-constructor-style-printer
            (lambda (c) 'cave)
            (lambda (c) (list (cave-pour-col c)
                              (cave-vectrix c)))))])

(struct point (x y)
    #:transparent
    #:mutable
    #:methods gen:custom-write
    [(define write-proc
        (make-constructor-style-printer
            (lambda (p) 'point)
            (lambda (p) (list (point-x p) (point-y p)))))])

(define (string->point s)
    (let ([point-parts (string-split s ",")])
        (point (string->number (car point-parts))
               (string->number (cadr point-parts)))))

(define (point- p1 p2)
    (point (- (point-x p1) (point-x p2))
           (- (point-y p1) (point-y p2))))

(define (point+ p1 p2)
    (point (+ (point-x p1) (point-x p2))
           (+ (point-y p1) (point-y p2))))

(define (points-between p1 p2)
    (let* ([point-diff (point- p2 p1)]
           [x (point-x point-diff)] [y (point-y point-diff)]
           [point-range (max (abs x) (abs y))]
           [xinc (if (eq? x 0) 0 (/ x (abs x)))]
           [yinc (if (eq? y 0) 0 (/ y (abs y)))])
        (for/list ([i (in-range point-range)])
            (point+ p1 (point (* i xinc) (* i yinc))))))

(define (expand-path path)
    (cond [(empty? path) '()]
          [(empty? (cdr path)) path]
          [else (append (points-between (car path) (cadr path))
                        (expand-path (cdr path)))]))

(define (get-bounding-box paths)
    (for*/fold ([bound-min (point 999 999)]
                [bound-max (point 0 0)])
               ([path paths]
                [path-point path])
        (values (point (min (point-x bound-min) (point-x path-point))
                       (min (point-y bound-min) (point-y path-point)))
                (point (max (point-x bound-max) (point-x path-point))
                       (max (point-y bound-max) (point-y path-point))))))

(define (make-vectrix rows cols v)
    (for/vector ([row (in-range (+ 1 rows))])
        (make-vector (+ 1 cols) v)))

(define (vectrix-ref vec pos)
    (vector-ref (vector-ref vec (point-y pos))
                    (point-x pos)))

(define (vectrix-set! vec pos v)
    (vector-set! (vector-ref vec (point-y pos))
                    (point-x pos) v))

(define (count-in-vectrix vec v)
    (for*/fold ([total 0])
               ([row vec]
                [cell row])
        (if (= cell v) (+ total 1) total)))

(define (print-vectrix vec [highlight-pos (point 0 0)] [highlight-val -1])
    (let ([temp-val (vectrix-ref vec highlight-pos)])
        (when (> highlight-val -1) (vectrix-set! vec highlight-pos highlight-val))
        (for ([row vec])
            (for ([cell row])
                (display (vector-ref cave-print-chars cell)))
            (display "\n"))
        (when (> highlight-val -1) (vectrix-set! vec highlight-pos temp-val))))

(define (vectrix->image vec)
    (define square-size 2)
    (define cell-colours (vector "Medium Gray" "Medium Brown" "Light Orange"))
    (define (cell-square cell-value)
        (square square-size "solid" (vector-ref cell-colours cell-value)))

    (define (row->image row)
        (apply beside (for/list ([cell row]) (cell-square cell))))

    (apply above (for/list ([row vec]) (row->image row))))

(define (paths->points paths)
    (flatten (for/list ([path paths]) (expand-path path))))

(define (run-sand-through-vectrix pos vec [xmax (- (vector-length (vector-ref vec 0)) 1)]
                                          [ymax (- (vector-length vec) 1)])
    (let* ([x (point-x pos)]
           [y (point-y pos)]
           [current (if (or (< x 0) (> x xmax)) space (vectrix-ref vec pos))])
        (if (or (> current space) (< x 0) (< y 0) (> x xmax) (>= y ymax)) #f
            (let ([below (if (< y ymax) (vectrix-ref vec (point+ pos (point 0 1))) space)]
                  [left (if (> x 0) (vectrix-ref vec (point+ pos (point -1 1))) space)]
                  [right (if (< x xmax) (vectrix-ref vec (point+ pos (point 1 1))) space)])
                (cond
                    [(= below space)
                        (run-sand-through-vectrix (point+ pos (point 0 1)) vec xmax ymax)]
                    [(= left space)
                        (run-sand-through-vectrix (point+ pos (point -1 1)) vec xmax ymax)]
                    [(= right space)
                        (run-sand-through-vectrix (point+ pos (point 1 1)) vec xmax ymax)]
                    [else (vectrix-set! vec pos sand)
                          #t])))))

(define (simulate-sand the-cave [total-sand 0])
    (if (run-sand-through-vectrix (point (cave-pour-col the-cave) 0) (cave-vectrix the-cave))
        (simulate-sand the-cave (+ total-sand 1))
        total-sand))


(define (paths->cave-vectrix paths bound-min bound-max)
    (let* ([xtop (- (point-x bound-max) (point-x bound-min))]
           [ytop (- (point-y bound-max) (point-y bound-min))]
           [offset (point (point-x bound-min) 0)]
           [grid (make-vectrix (point-y bound-max) xtop space)])
        (for ([p (paths->points paths)])
            (vectrix-set! grid (point- p offset) rock))
        grid))

(define (build-cave paths [pour-col 500])
    (let-values ([(bound-min bound-max) (get-bounding-box paths)])
        (cave (- pour-col (point-x bound-min))
              (paths->cave-vectrix paths bound-min bound-max))))


(define (input-parser input)
    (for/list ([line input])
        (for/list ([point-string (string-split line " -> ")])
            (string->point point-string))))

(define (part1 input)
    (let* ([the-cave (build-cave input)]
           [sand-count (simulate-sand the-cave)])
        (save-image (vectrix->image (cave-vectrix the-cave)) "part1.png")
        sand-count))

(define (add-floor-to-input input ymax)
    (append input
        (list
            (list (point 337 (+ 2 ymax))
                  (point 664 (+ 2 ymax))))))

(define (part2 input)
    (let-values ([(bound-min bound-max) (get-bounding-box input)])
        (let* ([input-with-floor (add-floor-to-input input (point-y bound-max))]
               [the-cave (build-cave input-with-floor)]
               [sand-count (simulate-sand the-cave)])
            (save-image (vectrix->image (cave-vectrix the-cave)) "part2.png")
            sand-count)))


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