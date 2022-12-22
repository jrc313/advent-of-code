#lang racket

(define test-mode (make-parameter #f))

(define parser
  (command-line #:usage-help "Run the AOC script"
                #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
                #:args () (void)))

(define (input-parser input)
  (foldl (λ (line steps)
           (let ([instruction (string-split line " ")])
             (append steps (make-list (string->number (cadr instruction)) (car instruction)))))
         '() input))

(define (apply-step step h)
  (cond [(string=? step "R") (cons (+ (car h) 1) (cdr h))]
        [(string=? step "L") (cons (- (car h) 1) (cdr h))]
        [(string=? step "U") (cons (car h) (+ (cdr h) 1))]
        [(string=? step "D") (cons (car h) (- (cdr h) 1))]))

(define (move-knot-coord coord dist-coord dist-other
                         [abs-dist-coord (abs dist-coord)] [abs-dist-other (abs dist-other)])
  (if (or (> abs-dist-coord 1) (and (= abs-dist-coord 1) (> abs-dist-other 1)))
      (+ coord (/ dist-coord abs-dist-coord))
      coord))

(define (move-tail h t)
  (if (empty? t) '()
      (let ([knot (car t)])
        (let ([dist-x (- (car h) (car knot))]
              [dist-y (- (cdr h) (cdr knot))])
          (let ([new-knot (cons (move-knot-coord (car knot) dist-x dist-y)
                                (move-knot-coord (cdr knot) dist-y dist-x))])
            (cons new-knot (move-tail new-knot (rest t))))))))

(define (run-steps steps [length 1] [h (cons 0 0)] [t (make-list length (cons 0 0))] [visited (set)])
  (let ([visited (set-add visited (last t))])
    (if (empty? steps) visited
        (let ([h-new (apply-step (car steps) h)])
          (run-steps (rest steps) length h-new (move-tail h-new t) visited)))))

(define (run-rope-sim steps length)
  (run-steps))

(define (part1 input)
  (set-count (run-steps input)))

(define (part2 input)
  (set-count (run-steps input 9)))

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