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

(define (parse-pairs input)
    (map (λ (line)
        (map (λ (pair)
            (map (λ (section) (
                string->number section))
                (string-split pair "-")))
            (string-split line ","))) input))

(define (contained-by? l r)
    (or (and (<= (car l) (car r)) (>= (cadr l) (cadr r)))
        (and (<= (car r) (car l)) (>= (cadr r) (cadr l)))))

(define (overlaps? l r)
    (or (and (<= (car l) (car r)) (>= (cadr l) (car r)))
        (and (<= (car r) (car l)) (>= (cadr r) (car l)))))

(define (part1 aoc-input)
    (foldl (λ (pairs total)
        (if (contained-by? (car pairs) (cadr pairs)) (+ total 1) total))
        0 (parse-pairs aoc-input)))

(define (part2 aoc-input)
    (foldl (λ (pairs total)
        (if (overlaps? (car pairs) (cadr pairs)) (+ total 1) total))
        0 (parse-pairs aoc-input)))

(define (run-part n proc)
    (define-values (result cpu real gc) (time-apply proc '()))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))