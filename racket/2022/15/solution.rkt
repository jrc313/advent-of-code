#lang racket

(require racket/struct)

(define test-mode (make-parameter #f))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              #:args () (void))

(struct point (x y)
    #:transparent
    #:mutable
    #:methods gen:custom-write
    [(define write-proc
        (make-constructor-style-printer
            (lambda (p) 'p)
            (lambda (p) (list (point-x p) (point-y p)))))])

(struct sensor (pos beacon dist)
    #:transparent
    #:mutable
    #:methods gen:custom-write
    [(define write-proc
        (make-constructor-style-printer
            (lambda (s) 's)
            (lambda (s) (list (sensor-pos s) (sensor-beacon s) (sensor-dist s)))))])

(define (sensor-x s)
    (point-x (sensor-pos s)))

(define (sensor-y s)
    (point-y (sensor-pos s)))

(define (manhattan-distance p1 p2)
    (+ (abs (- (point-x p1) (point-x p2)))
       (abs (- (point-y p1) (point-y p2)))))

(define (line->sensors line)
    (let* ([pattern #rx"^Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)$"]
           [m (regexp-match pattern line)]
           [sensor-pos (point (string->number (second m)) (string->number (third m)))]
           [beacon-pos (point (string->number (fourth m)) (string->number (fifth m)))]
           [dist (manhattan-distance sensor-pos beacon-pos)])
        (sensor sensor-pos beacon-pos dist)))

(define (sensor-range-at-row s row)
    (let* ([dist-from-row (abs (- (sensor-y s) row))]
           [dist-at-row (- (sensor-dist s) dist-from-row)])
    (if (> dist-from-row (sensor-dist s)) #f
        (cons (- (sensor-x s) dist-at-row) (+ (sensor-x s) dist-at-row)))))

(define (sensor-list-range-at-row sl row [clamp #f])
    (for/fold ([ranges '()]) ([s sl])
        (let* ([sensor-range (sensor-range-at-row s row)]
               [clamped-range (if clamp (clamp-range clamp sensor-range) sensor-range)])
            (if clamped-range (cons clamped-range ranges) ranges))))

(define (clamp-range clamp r)
    (cons (max (car clamp) (car r)) (min (cdr clamp) (cdr r))))

(define (sort-ranges ranges)
    (sort ranges (λ (a b)
        (<= (car a) (car b)))))

(define (fold-ranges ranges)
    (for/fold ([folded '()])
              ([r (sort-ranges ranges)])
        (if (empty? folded) (cons r folded)
            (let ([next-range (car folded)])
                (cond [(<= (cdr r) (cdr next-range)) folded]
                      [(<= (car r) (cdr next-range)) (cons (cons (car next-range) (cdr r)) (cdr folded))]
                      [else (cons r folded)])))))

(define (count-in-ranges ranges)
    (for/fold ([total 0])
              ([r ranges])
        (+ total (- (cdr r) (car r)) 1)))

(define (range-gap-at-row sensors row)
    (let ([ranges (fold-ranges (sensor-list-range-at-row sensors row))])
        (if (> (length ranges) 1) (- (car (car ranges)) 1) #f)))

(define (input-parser input)
    (for/list ([line input])
        (line->sensors line)))

(define (part1 input)
    (let* ([ranges (sensor-list-range-at-row input (if (test-mode) 10 2000000))]
           [folded-ranges (fold-ranges ranges)])
        (- (count-in-ranges folded-ranges) 1)))

(define (part2 input)
    (let* ([bound (if (test-mode) 20 4000000)]
           [clamp (cons 0 bound)])
        (for/or ([i (in-range (+ 1 bound))])
            (let ([gap (range-gap-at-row input i)])
                (if gap (+ i (* gap 4000000)) #f)))))

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