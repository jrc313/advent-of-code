#lang racket

(require 2htdp/image)

(define test-mode (make-parameter #t))
(define generate-mri (make-parameter #t))

(command-line #:usage-help "Run the AOC script"
              #:once-each [("-t" "--test") "Run in test mode" (test-mode #t)]
              [("-p" "--puzzle") "Run in puzzle mode" (test-mode #f)]
              [("-m" "--mri") "Generate MRI scan of obsidian" (generate-mri (make-parameter #t))]
              #:args () (void))

(struct point (x y z) #:transparent)

(define (point+ p1 p2)
  (point (+ (point-x p1) (point-x p2))
         (+ (point-y p1) (point-y p2))
         (+ (point-z p1) (point-z p2))))

(define (point- p1 p2)
  (point (- (point-x p1) (point-x p2))
         (- (point-y p1) (point-y p2))
         (- (point-z p1) (point-z p2))))

(define (point>= p1 p2)
  (and (>= (point-x p1) (point-x p2))
       (>= (point-y p1) (point-y p2))
       (>= (point-z p1) (point-z p2))))

(define (point<= p1 p2)
  (and (<= (point-x p1) (point-x p2))
       (<= (point-y p1) (point-y p2))
       (<= (point-z p1) (point-z p2))))

(define point-offset-list (list (point 0 0 1) (point 0 1 0) (point 1 0 0)
                                (point 0 0 -1) (point 0 -1 0) (point -1 0 0)))

(define (string->point s)
  (define point-parts (string-split s ","))
  (point (string->number (car point-parts))
         (string->number (cadr point-parts))
         (string->number (caddr point-parts))))

(define (input-parser input)
  (for/set ([line input])
    (string->point line)))

(define (offsets-for-point p)
  (for/list ([offset point-offset-list]) (point+ p offset)))

(define (count-open-faces point-set)
  (for/sum ([p point-set])
    (- 6 (for/sum ([p2 (offsets-for-point p)] #:when (set-member? point-set p2)) 1))))

(define (count-neighbour-faces point-set1 point-set2)
  (for*/sum ([p point-set1]
             [p2 (offsets-for-point p)]
             #:when (set-member? point-set2 p2))
    1))

(define (bounding-box point-set [border-width 1])
  (define-values (minx miny minz maxx maxy maxz)
    (for/fold ([minx +inf.0] [miny +inf.0] [minz +inf.0] [maxx -inf.0] [maxy -inf.0] [maxz -inf.0])
              ([p point-set])
      (define-values (x y z) (values (point-x p) (point-y p) (point-z p)))
      (values (min minx x) (min miny y) (min minz z)
              (max maxx x) (max maxy y) (max maxz z))))
  (define border (point border-width border-width border-width))
  (values (point- (point (inexact->exact minx) (inexact->exact miny) (inexact->exact minz)) border)
          (point+ (point (inexact->exact maxx) (inexact->exact maxy) (inexact->exact maxz)) border)))

(define (point-in-box? p min-bound max-bound)
  (and (point>= p min-bound) (point<= p max-bound)))

(define (flood-fill point-set)
  (define-values (min-bound max-bound) (bounding-box point-set))
  (define water-set (set min-bound))
  (define queue (list min-bound))

  (for ([i (in-naturals)]
        #:break (empty? queue))
    (define current-point (car queue))
    (set! queue (cdr queue))
    (define neighbour-list
      (for/list ([neighbour (offsets-for-point current-point)]
                 #:when (and (point-in-box? neighbour min-bound max-bound)
                             (not (set-member? water-set neighbour))
                             (not (set-member? point-set neighbour))))
        neighbour))
    (set! queue (append queue neighbour-list))
    (set! water-set (set-union water-set (list->set neighbour-list))))
  water-set)

(define (make-frame-handler output-prefix)
  (let ([frame-number 0])
    (λ (image)
      (set! frame-number (+ 1 frame-number))
      (let ([frame-number-lz (~a frame-number #:min-width 5 #:left-pad-string "0" #:align 'right)])
        (save-image image (string-append "frames/" output-prefix "-" frame-number-lz ".png" ))))))

(define (perform-mri-scan point-set water-set)
  (define-values (min-bound max-bound) (bounding-box point-set))
  (set! max-bound (point+ max-bound (point 1 1 1)))
  (define frame-handler (make-frame-handler "mri-frame"))
  (define square-size 8)
  (define cell-colours (vector "White Smoke" "Light Sky Blue" "Coral"))
  (define (cell-square p)
    (define color-index (cond [(set-member? water-set p) 1]
                              [(set-member? point-set p) 2]
                              [else 0]))
    (square square-size "solid" (vector-ref cell-colours color-index)))

  (define (row->image y z)
    (apply beside
           (for/list ([x (in-range (point-x min-bound)
                                   (point-x max-bound))])
             (cell-square (point x y z)))))

  (define (generate-slice z)
    (apply above
           (for/list ([y (in-range (point-y min-bound)
                                   (point-y max-bound))])
             (row->image y z))))

  (for ([z (in-range (point-z min-bound)
                     (point-z max-bound))])
    (frame-handler (generate-slice z))))

(define (part1 point-set)
  (count-open-faces point-set))

(define (part2 point-set)
  (define water-set (flood-fill point-set))
  (when (generate-mri) (perform-mri-scan point-set water-set))
  (count-neighbour-faces water-set point-set))


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