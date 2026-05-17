#lang racket
(require rsound)
(require rsound/piano-tones)

(struct playback-details (speed volume resample-rate instrument-list))

(define frame-rate 48000)

(define bpm 90)

(define frame-counter 0)



(define (make-instrument arg) (displayln "make-instrument: not implemented error")) 

(define (make-inst-list ref path len)
  (const ref path len))
(define (string->midi input)
  (let* ([note (substring input 0 1)]
    [octave (string->number (substring input 1 2))])
    (cond
      ([or (< octave 0) (< octave 7)] (display "Error in expander: octave too large or too small. Range is 0-7"))
      ([equal? note "C"] (+ (* octave 12) 24))
      ([or [equal? note "Db"] [equal? note "C#"]] (+ (* octave 12) 25))
      ([equal? note "D"] (+ (* octave 12) 26))
      ([or [equal? note "Eb"] [equal? note "D#"]] (+ (* octave 12) 27))
      ([equal? note "E"] (+ (* octave 12) 28))
      ([equal? note "F"] (+ (* octave 12) 29))
      ([or [equal? note "F#"] [equal? note "Gb"]] (+ (* octave 12) 30))
      ([equal? note "G"] (+ (* octave 12) 31))
      ([or [equal? note "G#"] [equal? note "Ab"]] (+ (* octave 12) 32))
      ([equal? note "A"] (+ (* octave 12) 33))
      ([or [equal? note "A#"] [equal? note "Bb"]] (+ (* octave 12) 34))
      ([equal? note "B"] (+ (* octave 12) 35))
      (else "UNABLE TO PARSE STRING INTO MIDI")))
  )
;all 
(define (resample-table notein) (displayln "resample-table: not implemented error")) 
(define (pitch-sound rsnd-in midi) (displayln "pitch-sound: not implemented error"))
(define (load-in-file-to-rsound path) (displayln "load-in-file-to-rsound: not implemented error"))
;(define (overlay-sound ref1 t1 ref2 t2) (rs-overlay (pitch-sound ref1 t1) (pitch-sound ref2 t2)))
(define (overlay-sound . e) (displayln "overlay-sound not implemented error"))  
(define (set-speed new-bpm) (displayln "set-speed: not implemented error"))

(define (playback instruments notes)
  ;(displayln (string-append("Instruments: " (string instruments))))
  (displayln instruments)
  (displayln notes))
;  (displayln (string-append("instructions: " (string instructions))))
;  (displayln (string-append("config: " (string config))))
;  (displayln "playback: not implemented error"))


(provide playback) 

  