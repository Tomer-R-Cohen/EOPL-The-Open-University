(module interp (lib "eopl.ss" "eopl")
  
  ;; interpreter for the LET language.  The \commentboxes are the
  ;; latex code for inserting the rules into the code in the book.
  ;; These are too complicated to put here, see the text, sorry.

  (require "drscheme-init.scm")

  (require "lang.scm")
  (require "data-structures.scm")
  (require "environments.scm")

  (provide value-of-program value-of)

;;;;;;;;;;;;;;;; the interpreter ;;;;;;;;;;;;;;;;

  ;; value-of-program : Program -> ExpVal
  ;; Page: 71
  (define value-of-program 
    (lambda (pgm)
      (cases program pgm
        (a-program (exp1)
          (value-of exp1 (init-env))))))

  ;; value-of : Exp * Env -> ExpVal
  ;; Page: 71
  (define value-of
    (lambda (exp env)
      (cases expression exp

        ;\commentbox{ (value-of (const-exp \n{}) \r) = \n{}}
        (const-exp (num) (num-val num))

        ;\commentbox{ (value-of (var-exp \x{}) \r) = (apply-env \r \x{})}
        (var-exp (var) (apply-env env var))

        ;\commentbox{\diffspec}
        (diff-exp (exp1 exp2)
          (let ((val1 (value-of exp1 env))
                (val2 (value-of exp2 env)))
            (let ((num1 (expval->num val1))
                  (num2 (expval->num val2)))
              (num-val
                (- num1 num2)))))

        ;\commentbox{\zerotestspec}
        (zero?-exp (exp1)
          (let ((val1 (value-of exp1 env)))
            (let ((num1 (expval->num val1)))
              (if (zero? num1)
                (bool-val #t)
                (bool-val #f)))))
              
        ;\commentbox{\ma{\theifspec}}
        (if-exp (exp1 exp2 exp3)
          (let ((val1 (value-of exp1 env)))
            (cases expval val1
              (bool-val (b) (if b
                              (value-of exp2 env)
                              (value-of exp3 env)))
              (num-val (n) (if (zero? n)
                              (value-of exp3 env)
                              (value-of exp2 env))))))

        ;\commentbox{\ma{\theletspecsplit}}
        (let-exp (var exp1 body)       
          (let ((val1 (value-of exp1 env)))
            (value-of body
              (extend-env var val1 env))))

        ;; casting extention
        (cast-exp (typ exp1)
          (let ((val1 (value-of exp1 env)))
            (cases type typ
              (int-type () (cases expval val1
                              (bool-val (b) (if b
                                              (num-val 1)
                                              (num-val 0)))
                              (else val1)))
              (bool-type () (cases expval val1
                              (num-val (n) (if (zero? n)
                                              (bool-val #f)
                                              (bool-val #t)))
                              (else val1))))))

        (do-exp (ids inits steps bools results)
          (letrec ((f (lambda (ids inits steps bools results)
                        (if (null? (car ids)
                          ((if (null? (car bools))
                              ((if (null? (car steps));; increment inits with steps
                                  (f () inits steps bools results)
                                  ()))
                              ((if (expval->bool (value-of (car bools) env) env)
                                  (value-of (car results))
                                  (f () inits steps (cdr bools) (cdr results))))))
                          (extend-env (car ids) (value-of (car inits) env))))))))) ;; inits the ids
        )))


  )

