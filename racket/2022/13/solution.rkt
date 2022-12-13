#lang racket

(define test-mode (make-parameter #t))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              #:args () (void))


(define (read-list s)
    (read (open-input-string
        (string-replace
            (string-replace
                (string-replace s "[" "(")
                "]" ")")
            "," " "))))

(define (input-parser input)
    (map (λ (i)
        (list (read-list (list-ref input i))
              (read-list (list-ref input (+ i 1)))))
        (range 0 (length input) 3)))

(define (compare-pairs p1 p2)
    ;(printf "Comparing ~a -> ~a\n" p1 p2)
    (cond [(and (empty? p1) (not (empty? p2))) #t]
          [(empty? p2) #f]
          [(or (list? p1) (list? p2))
            (compare-pairs (if (list? p1) (car p1) p1)
                           (if (list? p2) (car p2) p2))]
          
          [(< (car p1) (car p2)) #t]
          [(> (car p1) (car p2)) #f]
          [else (compare-pairs (cdr p1) (cdr p2))]))

(define (part1 input)
    (foldl (λ (i total)
        (let* ([pair (list-ref input i)]
               [p1 (car pair)] [p2 (cadr pair)]
               [in-order (compare-pairs p1 p2)])
            (if in-order (+ total i 1) total)))
        0 (range (length input))))

(define (part2 input)
    0)


(define (load-input path)
    (file->lines path))

(define (parse-input input-parser input)
    (define-values (result cpu real gc) (time-apply input-parser (list input)))
    (printf "🧹 Parse input: ~ams\n" cpu)
    (values (car result) cpu))

(define (run-part n proc input)
    (define-values (result cpu real gc) (time-apply proc (list input)))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define raw-input (load-input (if (test-mode) "test.txt" "input.txt")))
(define-values (parsed-input parse-time) (parse-input input-parser raw-input))
(define part-times
    (list (run-part 1 part1 parsed-input)
          (run-part 2 part2 parsed-input)))

(printf "\n")
(printf "⌛️ Total time: ~ams\n" (+ parse-time (apply + part-times)))