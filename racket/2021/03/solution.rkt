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

(define (string->numeric-vector s)
    s
)

(define (power-consumption input)
    (let ([freq-vec (make-vector (string-length (car input)))]
        [input-len (length input)])
        input-len))

(define (life-support-rating input)
    (+ 0))


(define (part1 aoc-input)
    (power-consumption aoc-input))

(define (part2 aoc-input)
    (life-support-rating aoc-input))

(let ([aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt"))])
    (time (printf "Part1: ~a\n" (part1 aoc-input)))
    (time (printf "Part2: ~a\n" (part2 aoc-input))))