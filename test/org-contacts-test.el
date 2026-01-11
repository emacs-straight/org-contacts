;;; test-org-contacts.el --- org-contacts testing -*- lexical-binding: t; -*-
;; -*- coding: utf-8 -*-

;; Copyright (C) 2020-2021 Free Software Foundation, Inc.

;;; Commentary:



;;; Code:

(require 'org-contacts)
(require 'ert)


(ert-deftest ert-test-org-contacts-property-email-value-extracting-regexp ()
  "Testing org-contacts property `EMAIL' value extracting regexp rule."
  (let ((regexp-rule
         ;; "\\[\\[mailto:\\(.*\\)\\]\\(\\[.*\\]\\)\\]" ; valid
         "\\[\\[mailto:\\(.*\\)\\]\\(\\[.*\\]\\)\\]\\(,\\ *\\[\\[mailto:\\(.*\\)\\]\\(\\[.*\\]\\)\\]\\)" ; valid
         ))
    (let ((pvalue "huangtc@outlook.com")) ; normal email
      (if (string-match regexp-rule pvalue)
          (should (string-equal (match-string 1 pvalue) "yantar92@posteo.net"))
        pvalue))

    (let ((pvalue "huangtc@outlook.com,")) ; has comma separator
      (if (string-match regexp-rule pvalue)
          (should (string-equal (match-string 1 pvalue) "yantar92@posteo.net"))
        pvalue))

    (let ((pvalue "huangtc@outlook.com, tristan.j.huang@gmail.com,"))
      (if (string-match regexp-rule pvalue)
          (should (string-equal (match-string 1 pvalue) "yantar92@posteo.net"))
        pvalue))

    (let ((pvalue "[[mailto:yantar92@posteo.net]]"))
      (if (string-match regexp-rule pvalue)
          (should (string-equal (match-string 1 pvalue) "yantar92@posteo.net"))
        pvalue))

    (let ((pvalue "[[mailto:yantar92@posteo.net][yantar92@posteo.net]]"))
      (if (string-match regexp-rule pvalue)
          (should (string-equal (match-string 1 pvalue) "yantar92@posteo.net"))
        pvalue))

    (let ((pvalue "[[mailto:yantar92@posteo.net][yantar92@posteo.net]], [[mailto:yantar92@gmail.com][yantar92@gmail.com]]"))
      (if (string-match regexp-rule pvalue)
          (should (string-equal (match-string 1 pvalue) "yantar92@posteo.net"))
        pvalue))
    ))

;;; literal testing

;; (let ((regexp-rule "\\[\\[mailto:\\(.*\\)\\]\\(\\[.*\\]\\)\\]")
;;       (pvalue "[[mailto:yantar92@posteo.net][yantar92@posteo.net]]"))
;;   (if (string-match regexp-rule pvalue)
;;       (match-string 1 pvalue)
;;     pvalue))

;; (let ((regexp-rule "\\[\\[mailto:\\(.*\\)\\]\\(\\[.*\\]\\)\\]\\(,\\ *\\[\\[mailto:\\(.*\\)\\]\\(\\[.*\\]\\)\\]\\)")
;;       (pvalue "[[mailto:yantar92@posteo.net][yantar92@posteo.net]], [[mailto:yantar92@gmail.com][yantar92@gmail.com]]"))
;;   (if (string-match regexp-rule pvalue)
;;       (match-string 1 pvalue)
;;     pvalue))

(ert-deftest ert-test-org-contacts-do-not-skip-during-update ()
  "The value of `org-agenda-skip-function-global' should not cause
org-contacts to skip contacts while updating the database."
  (let ((org-contacts-files (list (make-temp-file "ert-test-org-contacts" nil ".org")))
        (org-agenda-skip-function-global
         (lambda ()
           (org-agenda-skip-entry-if 'regexp "Smith")))
        (org-agenda-skip-function
         (lambda ()
           (org-agenda-skip-entry-if 'regexp "Henry"))))
    (with-temp-file (car org-contacts-files)
      (insert "\
* John Doe
:PROPERTIES:
:EMAIL: jdoe@example.com
:END:\n")
      (insert "\
* John Smith
:PROPERTIES:
:EMAIL: jsmith@example.com
:END:\n")
      (insert "\
* Jon Henry
:PROPERTIES:
:EMAIL: jhenry@example.com
:END:\n"))
    (should
     (seq-some (lambda (contact)
                 (string= "John Smith"
                          (car contact)))
               (org-contacts-db)))
    (should
     (seq-some (lambda (contact)
                 (string= "Jon Henry"
                          (car contact)))
               (org-contacts-db)))))



(provide 'test-org-contacts)

;;; test-org-contacts.el ends here
