#lang racket

(define test-mode (make-parameter #t))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              [("-p" "--puzzle") "Run in puzzle mode" (test-mode #f)]
              #:args () (void))

(struct point (x y z))

(define (string->point s)
  (define point-parts (string-split s ","))
  (list (string->number (car point-parts))
        (string->number (cadr point-parts))
        (string->number (caddr point-parts))))

(define (input-parser input)
  (for/list ([line input])
    (string->point line)))

(define (points-are-neighbours? p1 p2)
  (= 1 (for/sum ([a p1] [b p2])
         (abs (- a b)))))

(define (count-open-faces point-list)
  (for/fold ([open-faces 0])
            ([p point-list])
    (+ open-faces (- 6 (for/sum ([p2 point-list]
                                 #:when (points-are-neighbours? p p2))
                         1)))))

(define (part1 input)
  (count-open-faces input))

(define (part2 input)
  0)


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