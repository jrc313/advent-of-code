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

(define (rucksacks->compartments rucksacks)
    (map (λ (rucksack) (cons
        (substring rucksack 0 (/ (string-length rucksack) 2))
        (substring rucksack (/ (string-length rucksack) 2)))) rucksacks))

(define (find-dupes rucksacks)
    (map (λ (rucksack)
        (foldl (λ (item current)
            (if (string-contains? (cdr rucksack) (~a item)) item current))
            "" (string->list (car rucksack)))) rucksacks))

(define (get-priorities items)
    (map (λ (item) (- (char->integer item) (if (char-upper-case? item) 38 96))) items))

(define (group-three l)
    (if (empty? l) '()
        (cons (cons (car l) (cons (cadr l) (cons (caddr l) '()))) (group-three (cdddr l)))))

(define (find-dupes-three threes)
    (map (λ (group)
        (foldl (λ (item current)
            (if (and (string-contains? (cadr group) (~a item))
                     (string-contains? (caddr group) (~a item)))
                item current))
            "" (string->list (car group)))) threes))

(define (sum-priorities items)
    (foldl (λ (item total)
        (+ total (- (char->integer item) (if (char-upper-case? item) 38 96)))) 0 items))

(define (part1 aoc-input)
    (sum-priorities (find-dupes (rucksacks->compartments aoc-input))))

(define (part2 aoc-input)
    (sum-priorities(find-dupes-three (group-three aoc-input))))

(let ([aoc-input (parse-aoc-input (if (test-mode) "test.txt" "input.txt"))])
    (time (printf "Part1: ~a\n" (part1 aoc-input)))
    (time (printf "Part2: ~a\n" (part2 aoc-input))))