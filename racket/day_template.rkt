#lang racket

(define test-mode (make-parameter #f))

(define parser
 (command-line
    #:usage-help
    "Run the AOC script"
    
    #:once-each
    [("-t" "--test") "Run in test mode" (test-mode #t)]
    
    #:args () (void)))

(define (parse-aoc-input path)
    (file->lines path))


(define (part1 aoc-input)
    0)

(define (part2 aoc-input)
    0)

(define (run-part n proc)
    (define-values (result cpu real gc) (time-apply proc '()))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))