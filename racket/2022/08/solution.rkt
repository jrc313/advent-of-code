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

(define (transpose lst)
  (apply map list lst))

(define (input->matrix input)
    (map
        (λ (line)
            (map (λ (item) (char->integer item))
            (string->list line)))
        input))

(define (visible-in-row row [visible (list)] [tallest 0])
    (if (empty? row) visible
        (if (> (first row) tallest)
            (visible-in-row (rest row) (append visible '(#t)) (first row))
            (visible-in-row (rest row) (append visible '(#f)) tallest))))

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

(define (part1 aoc-input)
    (tall-trees-in-forest (input->matrix aoc-input)))

(define (part2 aoc-input)
    (best-view-in-forest (input->matrix aoc-input)))

(define (run-part n proc)
    (define-values (result cpu real gc) (time-apply proc '()))
    (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
    cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))
(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))