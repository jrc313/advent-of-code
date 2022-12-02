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

(define input-hash-part1 (hash "A" 'rock "B" 'paper "C" 'scissors "X" 'rock "Y" 'paper "Z" 'scissors))
(define input-hash-part2 (hash "A" 'rock "B" 'paper "C" 'scissors "X" 'lose "Y" 'draw "Z" 'win))
(define defeat-hash (hash 'rock 'paper 'paper 'scissors 'scissors 'rock))
(define win-hash (hash 'rock 'scissors 'paper 'rock 'scissors 'paper))
(define shape-score-hash (hash 'rock 1 'paper 2 'scissors 3))
(define result-score-hash (hash 'win 6 'draw 3 'lose 0))

(define (input->moves input input-hash)
    (map (λ (move)
        (map (λ (shape) (hash-ref input-hash shape)) (string-split move " ")))
        input))

(define (move-score move)
    (let ([opponent (car move)] [player (cadr move)])
        (cond
            [(equal? opponent player) 'draw]
            [(equal? (hash-ref defeat-hash opponent) player) 'win]
            [else 'lose])))

(define (get-shape-for-result opponent result)
    (cond
        [(equal? result 'draw) opponent]
        [(equal? result 'win) (hash-ref defeat-hash opponent)]
        [else (hash-ref win-hash opponent)]))

(define (view-strategy moves)
    (map (λ (move) (cons move (cons (move-score move) (hash-ref result-score-hash (move-score move))))) moves))

(define (run-part1-strategy moves)
    (foldl (λ (move score)
        (+ score (hash-ref result-score-hash (move-score move)) (hash-ref shape-score-hash (cadr move)))
    ) 0 moves))

(define (run-part2-strategy moves)
    (foldl (λ (move score)
        (+ score
            (hash-ref result-score-hash (cadr move))
            (hash-ref shape-score-hash (get-shape-for-result (car move) (cadr move))))
    ) 0 moves))

(define (part1 aoc-input)
    (run-part1-strategy (input->moves aoc-input input-hash-part1)))

(define (part2 aoc-input)
    (run-part2-strategy (input->moves aoc-input input-hash-part2)))

(let ([aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt"))])
    (time (printf "Part1: ~a\n" (part1 aoc-input)))
    (time (printf "Part2: ~a\n" (part2 aoc-input))))