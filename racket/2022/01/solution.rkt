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


(define (get-largest-n items new-item size)
    (let ([new-items (sort (cons new-item items) >)])
        (if (<= (length new-items) size) new-items
        (take new-items size))))


(define (get-largest inventory [size 1] [current-total 0] [largest '(0)])
    (cond
        [(empty? inventory) (apply + (get-largest-n largest current-total size))]
        [(not (string->number (car inventory))) (get-largest (cdr inventory) size 0 (get-largest-n largest current-total size))]
        [else (get-largest (cdr inventory) size (+ (string->number (car inventory)) current-total) largest)]
    ))

(define (part1 aoc-input)
    (get-largest aoc-input))

(define (part2 aoc-input)
    (get-largest aoc-input 3))

(define (run-part n proc)
    (define-values (result cpu real gc) (time-apply proc '()))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))