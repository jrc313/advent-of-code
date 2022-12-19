#lang racket

(require json)

(define test-mode (make-parameter #f))
 
(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              #:args () (void))
 
(define (string-replace-many s froms tos)
    (if (empty? froms) s
        (string-replace-many (string-replace s (car froms) (car tos)) (cdr froms) (cdr tos))))
 
(define (line->list s)
    (read-json (open-input-string s)))
 
(define (input-parser input)
    (map (λ (i)
        (list (line->list (list-ref input i))
              (line->list (list-ref input (+ i 1)))))
        (range 0 (length input) 3)))

(define (list< l1 l2)
    (let ([cmp (for/or ([a l1] [b l2]
                        #:when (or (list? a) (list? b) (not (= a b))))
                    (cond [(or (list? a) (list? b))
                           (list< (if (list? a) a (cons a '()))
                           (if (list? b) b (cons b '())))]
                          [(< a b) 1]
                          [(> a b) -1]
                          [else #f]))]
        )
        (cond [(not (boolean? cmp)) cmp]
              [(= (length l1) (length l2)) #f]
              [(< (length l1) (length l2)) 1]
              [else -1])))


(define (part1 input)
    (foldl (λ (i total)
        (let* ([pair (list-ref input i)]
               [p1 (car pair)] [p2 (cadr pair)]
               [in-order (list< p1 p2)])
            (if (= in-order 1) (+ total i 1) total)))
        0 (range (length input))))
 
(define (part2 input)
    (let*
        ([d1 (list (list 2))]
         [d2 (list (list 6))]
         [packets (foldl (λ (packet packet-list) (append packet-list (list (car packet) (cadr packet))))
                    (list (list (list 2)) (list (list 6))) input)]
         [sorted-packets (list->vector(sort packets (λ (a b) (= (list< a b) 1))))]
         [d1-pos (+ 1 (vector-member d1 sorted-packets))]
         [d2-pos (+ 1 (vector-member d2 sorted-packets))])
            (* d1-pos d2-pos)))
    
 

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