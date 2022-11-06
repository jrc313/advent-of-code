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
    (file->list path))

(define (get-n-items lst num)
    (if (and (not (empty? lst)) (> num 0)) (cons (car lst) (get-n-items (cdr lst) (- num 1)))
        '()))

(define (sum-seq-of num lst)
    (if (>= (length lst) num) (cons (apply + (get-n-items lst num)) (sum-seq-of num (rest lst)))
        '()))

(define (count-increases lst [increases 0])
    (if (<= (length lst) 1) increases
        (if (< (car lst) (cadr lst)) (count-increases (rest lst) (+ increases 1))
            (count-increases (rest lst) increases))))

(define (part1 aoc-input)
    (count-increases aoc-input))

(define (part2 aoc-input)
    (count-increases (sum-seq-of 3 aoc-input)))

(let ([aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt"))])
    (time (printf "Part1: ~a\n" (part1 aoc-input)))
    (time (printf "Part2: ~a\n" (part2 aoc-input))))