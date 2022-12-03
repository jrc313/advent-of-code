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

(let ([aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt"))])
    (printf "\n")
    (time (printf "🎄 Part 1: ~a\n" (part1 aoc-input)))
    (printf "\n")
    (time (printf "🎄 Part 2: ~a\n" (part2 aoc-input)))
    (printf "\n"))