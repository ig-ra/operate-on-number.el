(require 'ert)
(require 'operate-on-number)

;; Test wrapper functions
(defun oon-test-op (op number expected)
 "Test OPERATION on NUMBER expecting EXPECTED result.
OPERATION is a character like ?+, ?-, ?b etc."
  (with-temp-buffer
    (insert (format "%s" number)) ; either number or string
    (goto-char (point-min))
    (apply-operation-to-number-at-point op nil)
    (message (format "here |%S|%S|" (buffer-string) expected))
    (should (equal (buffer-string) expected))))

(defun oon-test-chain (number &rest operations)
  "Test chain of operations starting from NUMBER.
OPERATIONS is a list of (op . expected) pairs where:
- op is the operation character (?x, ?b, ?d,  etc)
- expected is the expected result after operation"
  (with-temp-buffer
    (insert (format "%s" number))
    (dolist (op-pair operations)
      (let ((op (car op-pair))
            (expected (cdr op-pair)))
        (goto-char (point-min))
        (apply-operation-to-number-at-point op nil)
        (should (equal (buffer-string) expected))))))


(ert-deftest test-operate-on-number-operations ()
  "Test various operations from operate-on-number-at-point-alist."

  ;; Arithmetic operations
  (oon-test-op ?+ 11 "12")       ; increment
  (oon-test-op ?- "100" "99")    ; decrement
  (oon-test-op ?* 25 "50")       ; multiply by 2
  (oon-test-op ?/ "32" "16")     ; divide by 2

  ;; Bitwise operations
  (oon-test-op ?< "21" "42")     ; left shift by 1
  (oon-test-op ?> "84" "42")     ; right shift by 1

  ;; Format operations
  (oon-test-op ?b "10" "0b1010") ; to binary
  (oon-test-op ?x "255" "0xff")  ; to hex lowercase
  (oon-test-op ?X 15 "0XF")      ; to hex uppercase
  (oon-test-op ?o "64" "0o100")  ; to octal

  ;; Base conversion. TODO: should we add base prefix to allow chain ops?
  (oon-test-op ?# "0xAA" "170") ; to base 10
  )

(ert-deftest test-operate-on-number-chains ()
  "Test various operation chains."

  ;; Decimal -> Hex -> Binary -> HEX -> Decimal
  (oon-test-chain "10"
                  '(?x . "0xa")
                  '(?b . "0b1010")
                  '(?X . "0XA")
                  '(?d . "10"))

  ;; Hex -> Binary -> Decimal -> HEX
  (oon-test-chain "0xff"
                  '(?b . "0b11111111")
                  '(?d . "255")
                  '(?X . "0XFF"))

  ;; Hex -> hex -> HEX -> add -> decimal
  (oon-test-chain "0xAa"
                  '(?x . "0xaa")
                  '(?X . "0XAA")
                  '(?+ . "0XAB")
                  '(?d . "171"))
  )
