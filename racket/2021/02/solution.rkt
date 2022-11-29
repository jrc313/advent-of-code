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

(define (follow-instructions1 instructions [h 0] [v 0])
    (if (empty? instructions) (* h v)
        (let ([inst (string->symbol (car (string-split (car instructions) " ")))]
                [amount (string->number (cadr (string-split (car instructions) " ")))])
            (cond
                [(symbol=? inst 'forward) (follow-instructions1 (rest instructions) (+ h amount) v)]
                [(symbol=? inst 'down) (follow-instructions1 (rest instructions) h (+ v amount))]
                [(symbol=? inst 'up) (follow-instructions1 (rest instructions) h (- v amount))]
                [else (printf "Bad instruction ~a" inst)]))))

(define (follow-instructions2 instructions [h 0] [v 0] [a 0])
    (if (empty? instructions) (* h v)
        (let ([inst (string->symbol (car (string-split (car instructions) " ")))]
                [amount (string->number (cadr (string-split (car instructions) " ")))])
            (cond
                [(symbol=? inst 'forward) (follow-instructions2 (rest instructions) (+ h amount) (+ v (* a amount)) a)]
                [(symbol=? inst 'down) (follow-instructions2 (rest instructions) h v (+ a amount))]
                [(symbol=? inst 'up) (follow-instructions2 (rest instructions) h v (- a amount))]
                [else (printf "Bad instruction ~a" inst)]))))

(define (part1 aoc-input)
    (follow-instructions1 aoc-input))

(define (part2 aoc-input)
    (follow-instructions2 aoc-input))

(let ([aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt"))])
    (time (printf "Part1: ~a\n" (part1 aoc-input)))
    (time (printf "Part2: ~a\n" (part2 aoc-input))))