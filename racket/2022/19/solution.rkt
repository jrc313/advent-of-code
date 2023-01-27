#lang racket

(require racket/struct)

(define test-mode (make-parameter #t))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              [("-p" "--puzzle") "Run in puzzle mode" (test-mode #f)]
              #:args () (void))

(struct inventory (ore clay obsidian geode))
(struct blueprint (ore clay obsidian)
  #:transparent
  #:mutable
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (b) 'blueprint)
      (lambda (b) (list 'ore (blueprint-ore b) 'clay (blueprint-clay b) 'obsidian (blueprint-obsidian b)))))])
(struct robot (type ore clay obsidian) #:transparent)
(define robot-type-hash (hash 'ore 0 'clay 1 'obsidian 2 'geode 3))

(define (input-parser input)
  (for/vector ([line input])
    (define pattern #rx"^Blueprint [0-9]+: Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian.$")
    (define m (regexp-match pattern line))
    (hash 'ore (blueprint (second m) 0 0)
          'clay (blueprint (third m) 0 0)
          'obsidian (blueprint (fourth m) (fifth m) 0)
          'geode (blueprint 0 (sixth m) (seventh m)))))

(define (part1 input)
  (pretty-display input)
  0)

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