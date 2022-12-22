#lang racket

(define test-mode (make-parameter #f))

(define parser
  (command-line #:usage-help "Run the AOC script"
                #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
                #:args () (void)))

(define (input-parser input)
  (exec-program input))

(define (exec-program instructions [state '()] [x-accum 1])
  (if (empty? instructions) state
      (if (string=? (car instructions) "noop")
          (exec-program (cdr instructions) (append state (list x-accum)) x-accum)
          (let ([new-x (string->number (cadr (string-split (car instructions) " ")))])
            (exec-program (cdr instructions) (append state (list x-accum (+ x-accum new-x))) (+ x-accum new-x))))))

(define (get-states-at-cycles state cycles [states '()])
  (if (empty? cycles) states
      (get-states-at-cycles state (cdr cycles)
                            (append states (list (* (list-ref state (- (car cycles) 2)) (car cycles)))))))

(define (render-row state [beam-pos 1] [row ""])
  (if (empty? state) row
      (render-row (cdr state) (add1 beam-pos)
                  (string-append row
                                 (if (and (>= beam-pos (sub1 (car state)))
                                          (<= beam-pos (add1 (car state))))
                                     "🟥" "⬜️")))))

(define (render-screen state [screen '()])
  (if (empty? state) screen
      (render-screen (drop state 40)
                     (append screen (list (render-row (take state 40)))))))

(define (print-state-rows state)
  (unless (empty? state)
    (printf "~a\n" (take state 40))
    (print-state-rows (drop state 40))))

(define (part1 input)
  (apply + (get-states-at-cycles input (list 20 60 100 140 180 220))))

(define (part2 input)
  (for ([row (render-screen input)])
    (printf "~a\n" row))
  "")


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