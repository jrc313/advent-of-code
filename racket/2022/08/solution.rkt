#lang racket

(define test-mode (make-parameter #f))

(define parser
  (command-line #:usage-help "Run the AOC script"
                #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
                #:args () (void)))

(define (transpose lst)
  (apply map list lst))

(define (input->matrix input)
  (map (λ (line)
         (map (λ (item) (- (char->integer item) 48))
              (string->list line)))
       input))

(define (visible-in-row row [visible (list)] [tallest 0])
  (cond [(empty? row) visible]
        [(= tallest 9) (append visible (make-list (length row) #f))]
        [(> (first row) tallest) (visible-in-row (rest row) (append visible '(#t)) (first row))]
        [(visible-in-row (rest row) (append visible '(#f)) tallest)]))

(define (view-score-from-point tree-h view)
  (if (empty? view) 0
      (let ([view-distance (index-where view (λ (h) (>= h tree-h)))])
        (if (not (identity view-distance))
            (length view)
            (+ view-distance 1)))))

(define (view-scores-in-row row [scores (list)])
  (if (empty? row) scores
      (view-scores-in-row
       (rest row)
       (append scores
               (list (view-score-from-point (first row) (rest row)))))))

(define (process-forest forest proc combine-proc)
  (let (
        [horizontal
         (map
          (λ (line) (map combine-proc (proc line) (reverse (proc (reverse line)))))
          forest)]
        [vertical
         (transpose
          (map (λ (line) (map combine-proc (proc line) (reverse (proc (reverse line)))))
               (transpose forest)))])
    (flatten
     (map (λ (hrow vrow)
            (map combine-proc hrow vrow))
          horizontal vertical))))

(define (tall-trees-in-forest forest)
  (length (filter identity (process-forest forest visible-in-row (λ (a b) (or a b))))))

(define (best-view-in-forest forest)
  (foldl (λ (tree tallest)
           (if (> tree tallest) tree tallest))
         0 (process-forest forest view-scores-in-row *)))

(define (input-parser input)
  (input->matrix input))

(define (part1 input)
  (tall-trees-in-forest input))

(define (part2 input)
  (best-view-in-forest input))


(define (load-input path)
  (file->lines path))

(define (parse-input input-parser input)
  (define-values (result cpu real gc) (time-apply input-parser (list input)))
  (printf "🧹 Parse input: ~ams\n" cpu)
  (when (test-mode) (pretty-display (car result)))
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