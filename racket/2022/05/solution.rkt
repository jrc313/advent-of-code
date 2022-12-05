#lang racket

(define test-mode (make-parameter #f))

(define parser
 (command-line
    #:usage-help
    "Run the AOC script"
    
    #:once-each
    [("-t" "--test") "Run in test mode" (test-mode #t)]
    
    #:args () (void)))

(define (get-input path)
    (file->lines path))

(struct crane (stacks instructions))
(struct instruction (amt from to))

(define (parse-rearrangement-procedure input)
    (let-values ([(stacks instructions) (splitf-at input (λ (item) (not (equal? item ""))))])
        (crane (parse-stacks (take stacks (- (length stacks) 1))) (parse-instructions (cdr instructions)))))
    
(define (parse-stacks stacks)
    (let ([stack-count (/ (+ (string-length (car stacks)) 1) 4)])
        (let ([stack-vector (make-vector stack-count '())])
            (foldr (λ (layer n) 
                (for ([i (range stack-count)])
                    (let ([crate (string-ref layer (+ (* i 4) 1))])
                        (if (char-whitespace? crate) 0
                            (vector-set! stack-vector i (cons crate (vector-ref stack-vector i)))))))
                0 stacks)
            stack-vector)))

(define (parse-instructions instructions)
    (map (λ (line)
        (let ([step (regexp-match #rx"^move ([0-9]+) from ([0-9]+) to ([0-9]+)$" line)])
            (instruction (string->number (second step))
                         (- (string->number (third step)) 1)
                         (- (string->number (fourth step)) 1))))
        instructions))

(define (run-crane the-crane model)
    (vector-map (λ (stack) (first stack))
        (foldl (λ (instruction stacks)
            (let ([amt (instruction-amt instruction)]
                [from (instruction-from instruction)]
                [to (instruction-to instruction)])
                (vector-set! stacks to
                    (append
                        (if (eq? model '9001)
                            (take (vector-ref stacks from) amt)
                            (reverse (take (vector-ref stacks from) amt)))
                        (vector-ref stacks to)))
                (vector-set! stacks from (drop (vector-ref stacks from) amt))
                stacks))
            (crane-stacks the-crane) (crane-instructions the-crane))))

(define (part1 aoc-input)
    (run-crane (parse-rearrangement-procedure aoc-input) '9000))

(define (part2 aoc-input)
    (run-crane (parse-rearrangement-procedure aoc-input) '9001))

(define (run-part n proc)
    (define-values (result cpu real gc) (time-apply proc '()))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define aoc-input (get-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))