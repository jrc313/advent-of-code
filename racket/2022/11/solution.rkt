#lang racket

(require racket/struct)
(require math/number-theory)

(define test-mode (make-parameter #f))

(define parser
    (command-line #:usage-help "Run the AOC script"
                  #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
                  #:args () (void)))

(struct monkey (items inspect throw-to divisor)
    #:transparent
    #:mutable
    #:methods gen:custom-write
    [(define write-proc
        (make-constructor-style-printer
            (lambda (m) 'monkey)
            (lambda (m) (list (monkey-divisor m) (monkey-items m)))))])

(define (take-up-to l n)
    (if (or (zero? n) (null? l)) '()
        (cons (car l) (take-up-to (cdr l) (- n 1)))))

(define (create-inspect parts)
    (let ([op (if (string=? (second parts) "*") * +)]
          [b (string->number (third parts))])
        (λ (worry-level) (op worry-level (if b b worry-level)))))

(define (create-throw-to divisor throw-to-true throw-to-false)
    (λ (worry-level)
        (if (divides? divisor worry-level) throw-to-true throw-to-false)))

(define (string->number-list s sep)
    (map (λ (item) (string->number item)) (string-split s sep)))

(define (input-parser input [monkeys (make-vector (ceiling (/ (length input) 7)))])
    (for ([i (in-range 0 (length input) 7)])
        (vector-set! monkeys (string->number (substring (list-ref input i) 7 8))
            (monkey (string->number-list (substring (list-ref input (+ i 1)) 18) ", ")
                    (create-inspect (string-split (substring (list-ref input (+ i 2)) 19) " "))
                    (create-throw-to 
                        (string->number (substring (list-ref input (+ i 3)) 21))
                        (string->number (substring (list-ref input (+ i 4)) 29))
                        (string->number (substring (list-ref input (+ i 5)) 30)))
                    (string->number (substring (list-ref input (+ i 3)) 21)))))
    monkeys)

(define (monkey-around monkeys monkey-activity relief? worry-mod)
    (for ([monkey monkeys]
          [i (in-range 0 (vector-length monkeys))])
        (vector-set! monkey-activity i (+ (vector-ref monkey-activity i) (length (monkey-items monkey))))
        (for ([item (monkey-items monkey)])
            (let ([inspected-item ((monkey-inspect monkey) item)])
                (let ([new-item (if relief? (floor (/ inspected-item worry-mod)) (modulo inspected-item worry-mod))])
                    (let ([throw-to-monkey-pos ((monkey-throw-to monkey) new-item)])
                        (let ([throw-to-monkey (vector-ref monkeys throw-to-monkey-pos)])
                            (set-monkey-items! throw-to-monkey (append (monkey-items throw-to-monkey) (list new-item)))
                            (vector-set! monkeys throw-to-monkey-pos throw-to-monkey))))))
        (set-monkey-items! monkey '())
        (vector-set! monkeys i monkey))
    monkey-activity)

(define (monkey-around-n-times monkeys n [relief? #t])
    (let ([monkey-activity (make-vector (vector-length monkeys) 0)])
        (for ([i (in-range n)])
            (monkey-around monkeys monkey-activity relief?
                (if relief? 3
                    (foldl (λ (monkey mod-total) (* (monkey-divisor monkey) mod-total))
                        1 (vector->list monkeys)))))
        monkey-activity))

(define (part1 input)
    (apply * (take (sort (vector->list (monkey-around-n-times input 20)) >) 2)))

(define (part2 input)
    (apply * (take (sort (vector->list (monkey-around-n-times input 10000 #f)) >) 2)))


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
    (list (run-part 1 part1 (input-parser raw-input))
          (run-part 2 part2 (input-parser raw-input))))

(printf "\n")
(printf "⌛️ Total time: ~ams\n" (+ parse-time (apply + part-times)))