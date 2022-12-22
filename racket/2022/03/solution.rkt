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

(define (take-up-to n l)
  (if (or (zero? n) (null? l)) '()
      (cons (car l) (take-up-to (- n 1) (cdr l)))))

(define (drop-up-to n l)
  (if (null? l) '()
      (if (zero? n) l
          (drop-up-to (- n 1) (cdr l)))))

(define (chunk-n n l)
  (if (empty? l) '()
      (cons (take-up-to n l) (chunk-n n (drop-up-to n l)))))

(define (rucksacks->compartments rucksacks)
  (map (λ (rucksack) (cons
                      (substring rucksack 0 (/ (string-length rucksack) 2))
                      (cons (substring rucksack (/ (string-length rucksack) 2)) '()))) rucksacks))

(define (sum-priorities items)
  (foldl (λ (item total)
           (+ total (- (char->integer item) (if (char-upper-case? item) 38 96))))
         0 items))

(define (part1 aoc-input)
  (sum-priorities (map (λ (rucksack)
                         (car (set-intersect
                               (string->list (car rucksack))
                               (string->list (cadr rucksack)))))
                       (rucksacks->compartments aoc-input))))

(define (part2 aoc-input)
  (sum-priorities(map (λ (group)
                        (car (set-intersect
                              (string->list (car group))
                              (string->list (cadr group))
                              (string->list (caddr group))))) (chunk-n 3 aoc-input))))

(define (run-part n proc)
  (define-values (result cpu real gc) (time-apply proc '()))
  (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
  cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))