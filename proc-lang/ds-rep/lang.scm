(module lang (lib "eopl.ss" "eopl")                

  ;; grammar for the PROC language
  
  (require "drscheme-init.scm")
  
  (provide (all-defined-out)) 

  ;;;;;;;;;;;;;;;; grammatical specification ;;;;;;;;;;;;;;;;
  
  (define the-lexical-spec
    '((whitespace (whitespace) skip)
      (comment ("%" (arbno (not #\newline))) skip)
      (identifier
       (letter (arbno (or letter digit "_" "-" "?")))
       symbol)
      (number (digit (arbno digit)) number)
      (number ("-" digit (arbno digit)) number)
      ))
  
  (define the-grammar
    '((program (expression) a-program)

      (expression (number) const-exp)
      (expression
        ("-" "(" expression "," expression ")")
        diff-exp)
      
      (expression
       ("zero?" "(" expression ")")
       zero?-exp)

      (expression
       ("if" expression "then" expression "else" expression)
       if-exp)

      (expression (identifier) var-exp)

      (expression
       ("let" identifier "=" expression "in" expression)
      
      ;;tuple extention
      (temps
        (identifier)
        single-temp)

      ;;tuple extention
      (temps
        ("[" (separated-list identifier "_") "]")
        multi-temp)

      (expression
       ("let" temps "=" expression "in" expression)
       let-exp)   

      (expression
       ("proc" "(" identifier ")" expression)
       proc-exp)

      (expression
       ("(" expression expression ")")
       call-exp)
<<<<<<< HEAD
=======

<<<<<<<< HEAD:proc-lang/proc-rep/lang.scm
========
      (expression
        ("fold" expression expression "[" (separated-list expression ",") "]")
        fold-exp)
>>>>>>>> 9e0672b72ed8ba3b493f99e34ebc81ba79605a27:proc-lang/ds-rep/lang.scm

      (expression
        ("<" (separated-list expression ",") ">")
        tuple-exp)

<<<<<<<< HEAD:proc-lang/proc-rep/lang.scm
      (temps
        (identifier)
        single-temp)

      (temp-id
        (identifier)
        temp-identifier)

      (temp-id
        ("_")
        temp-underscore)

      (temps
        ("[" (separated-list temp-id ",") "]")
        multi-temp)

========
>>>>>>>> 9e0672b72ed8ba3b493f99e34ebc81ba79605a27:proc-lang/ds-rep/lang.scm
      
>>>>>>> 9e0672b72ed8ba3b493f99e34ebc81ba79605a27
      
      ))

  ;;;;;;;;;;;;;;;; sllgen boilerplate ;;;;;;;;;;;;;;;;
  
  (sllgen:make-define-datatypes the-lexical-spec the-grammar)
  
  (define show-the-datatypes
    (lambda () (sllgen:list-define-datatypes the-lexical-spec the-grammar)))
  
  (define scan&parse
    (sllgen:make-string-parser the-lexical-spec the-grammar))
  
  (define just-scan
    (sllgen:make-string-scanner the-lexical-spec the-grammar))
  
  )
