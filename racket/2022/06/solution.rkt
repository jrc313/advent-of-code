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

(define (first-n-unique signal n [depth 0])
  (if (eq? n (length (remove-duplicates (take signal n))))
      (+ depth n)
      (first-n-unique (rest signal) n (+ depth 1))))

(define (part1 aoc-input)
  (first-n-unique (string->list (first aoc-input)) 4))

(define (part2 aoc-input)
  (first-n-unique (string->list (first aoc-input)) 14))

(define (run-part n proc)
  (define-values (result cpu real gc) (time-apply proc '()))
  (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
  cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))