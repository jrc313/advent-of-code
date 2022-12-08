#lang racket

(define test-mode (make-parameter #f))

(define parser
 (command-line
    #:usage-help
    "Run the AOC script"
    
    #:once-each
    [("-t" "--test") "Run in test mode" (test-mode #t)]
    
    #:args () (void)))

(define (input-parser input)
    input)

(define (part1 aoc-input)
    0)

(define (part2 aoc-input)
    0)


(define (load-input path)
    (file->lines path))

(define (parse-input input-parser input)
    (define-values (result cpu real gc) (time-apply input-parser (list input)))
    (printf "🛠  Parse input: ~ams\n" cpu)
    (values (car result) cpu))

(define (run-part n proc input)
    (define-values (result cpu real gc) (time-apply proc (list input)))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define input (load-input (if (test-mode) "test.txt" "input.txt")))
(define-values (parsed-input parse-time) (parse-input input-parser input))
(define part-times
    (list (run-part 1 part1 parsed-input)
          (run-part 2 part2 parsed-input)))

(printf "⏱  Total time: ~ams\n" (+ parse-time (apply + part-times)))