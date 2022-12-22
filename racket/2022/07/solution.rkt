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

(define (cwd->path cwd)
  (string-join (reverse cwd) "."))

(define (terminal->fs terminal [fs (make-immutable-hash)] [cwd '()])
  (if (stream-empty? terminal) fs
      (let ([line (stream-first terminal)])
        (cond
          [(string-prefix? line "$ cd ..") (terminal->fs (stream-rest terminal) fs (cdr cwd))]
          [(string-prefix? line "$ cd")
           (let ([new-cwd (cons (third (string-split line)) cwd)])
             (terminal->fs (stream-rest terminal)
                           (hash-set fs (cwd->path new-cwd) 0)
                           new-cwd))]
          [(string->number (substring line 0 1))
           (let ([path (cwd->path cwd)])
             (terminal->fs (stream-rest terminal)
                           (hash-set fs path
                                     (+ (hash-ref fs path)
                                        (string->number (car (string-split line " ")))))
                           cwd))]))))

(define (calculate-total-sizes fs)
  (let ([paths (hash-keys fs)])
    (foldl (λ (path fs)
             (foldl
              (λ (key fs) (hash-set fs path (+ (hash-ref fs key) (hash-ref fs path))))
              fs
              (filter (λ (item) (and (string-prefix? item path)
                                     (not (string=? item path)))) paths)))
           fs
           (sort paths (λ (a b) (< (length (string-split a "."))
                                   (length (string-split b "."))))))))

(define (sum-of-less-than-n fs n)
  (foldl (λ (size total) (+ size total)) 0 (filter (λ (size) (< size n)) (hash-values fs))))

(define (delete-to-free-required-space fs required total)
  (let ([to-delete (- required (- total (hash-ref fs "/")))])
    (car (sort (filter (λ (size) (>= size to-delete)) (hash-values fs)) <))))

(define (get-fs input)
  (calculate-total-sizes
   (terminal->fs
    (filter-not (
                 λ (item)
                  (or (string-prefix? item "$ ls") (string-prefix? item "dir")))
                aoc-input))))


(define (part1 aoc-input)
  (sum-of-less-than-n (get-fs aoc-input) 100001))

(define (part2 aoc-input)
  (delete-to-free-required-space (get-fs aoc-input) 30000001 70000000))

(define (run-part n proc)
  (define-values (result cpu real gc) (time-apply proc '()))
  (printf "⭐️ Part ~a ~ams: ~a\n" n cpu (car result))
  cpu)

(define aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt")))

(define times (list (run-part 1 (λ () (part1 aoc-input))) (run-part 2 (λ () (part2 aoc-input)))))

(printf "⏱  Total time: ~ams\n" (apply + times))