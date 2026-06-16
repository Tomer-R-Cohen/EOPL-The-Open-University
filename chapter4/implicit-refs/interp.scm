(module interp (lib "eopl.ss" "eopl")
  
  ;; interpreter for the IMPLICIT-REFS language

  (require "drscheme-init.scm")

  (require "lang.scm")
  (require "data-structures.scm")
  (require "environments.scm")
  (require "store.scm")
  
  (provide value-of-program value-of instrument-let instrument-newref)

;;;;;;;;;;;;;;;; switches for instrument-let ;;;;;;;;;;;;;;;;

  (define instrument-let (make-parameter #f))

;;;;;;;;;;;;;;;; the interpreter ;;;;;;;;;;;;;;;;

  (define value-of-program 
    (lambda (pgm)
      (initialize-store!)
      (cases program pgm
        (a-program (exp1)
          (value-of exp1 (init-env))))))

  (define value-of
    (lambda (exp env)
      (cases expression exp

        (const-exp (num) (num-val num))

        (var-exp (var) (deref (apply-env env var)))

        (diff-exp (exp1 exp2)
          (let ((val1 (value-of exp1 env))
                (val2 (value-of exp2 env)))
            (let ((num1 (expval->num val1))
                  (num2 (expval->num val2)))
              (num-val
                (- num1 num2)))))

        (zero?-exp (exp1)
          (let ((val1 (value-of exp1 env)))
            (let ((num1 (expval->num val1)))
              (if (zero? num1)
                (bool-val #t)
                (bool-val #f)))))
              
        (if-exp (exp1 exp2 exp3)
          (let ((val1 (value-of exp1 env)))
            (if (expval->bool val1)
              (value-of exp2 env)
              (value-of exp3 env))))

        (let-exp (var exp1 body)       
          (let ((v1 (value-of exp1 env)))
            (value-of body
              (extend-env var (newref v1) env))))
        
        (proc-exp (var body)
          (proc-val (procedure var body env)))

        (call-exp (rator rand)
          (let ((proc (expval->proc (value-of rator env)))
                (arg (value-of rand env)))
            (apply-procedure proc arg)))

        (letrec-exp (p-names b-vars p-bodies letrec-body)
          (value-of letrec-body
            (extend-env-rec* p-names b-vars p-bodies env)))

        (begin-exp (exp1 exps)
          (letrec 
            ((value-of-begins
               (lambda (e1 es)
                 (let ((v1 (value-of e1 env)))
                   (if (null? es)
                     v1
                     (value-of-begins (car es) (cdr es)))))))
            (value-of-begins exp1 exps)))

        (assign-exp (var exp1)
          (begin
            (setref!
              (apply-env env var)
              (value-of exp1 env))
            (num-val 27)))

        ;; (switch-exp (e1 typs ids bools exps defexp)
        ;;   (let* ((val1 (value-of e1 env))
        ;;         (type1 (cases expval val1
        ;;                   (num-val (num) (num-type))
        ;;                   (bool-val (bool) (bool-type))
        ;;                   (proc-val (proc) (proc-type))
        ;;                   (ref-val (ref) (eopl:error 'switch-exp "cannot switch on a reference")))))
        ;;     (let loop-f ((typs typs) (ids ids) (bools bools) (exps exps) (env env))
        ;;       (if (null? typs)
        ;;         (value-of defexp env)
        ;;         (if (cases type (car typs)
        ;;               (num-type () (cases type type1 (num-type () #t) (else #f)))
        ;;               (bool-type () (cases type type1 (bool-type () #t) (else #f)))
        ;;               (proc-type () (cases type type1 (proc-type () #t) (else #f))))
        ;;           (let ((new-env (extend-env (car ids) (newref val1) env)))
        ;;             (if (expval->bool (value-of (car bools) new-env))
        ;;               (value-of (car exps) new-env)
        ;;               (loop-f (cdr typs) (cdr ids) (cdr bools) (cdr exps) env)))
        ;;           (loop-f (cdr typs) (cdr ids) (cdr bools) (cdr exps) env))))))


        (return-exp (gen)
          (let ((g (expval->gen (value-of gen env))))
            (cases gen g
              (generator (var vals body env)
                (let ((new-env (extend-env var (newref (car (deref vals))) env)))
                  (begin
                    (setref!
                      vals
                      (cdr (deref vals)))
                    (value-of body new-env)))))))
                
        (empty-exp (gen)
          (let ((g (expval->gen (value-of gen env))))
            (cases gen g
              (generator (var vals body env)
                (if (null? (deref vals))
                  (bool-val #f)
                  (bool-val #t)))
              (else (eopl:error 'empty-exp "variable isnt a generator")))))

        (gen-exp (var exps retexp)
          (gen-val (generator var (newref (map (lambda (v) (value-of v env)) exps)) retexp env)))

    )))

  (define apply-procedure
    (lambda (proc1 arg)
      (cases proc proc1
        (procedure (var body saved-env)
          (let ((r (newref arg)))
            (let ((new-env (extend-env var r saved-env)))
              (if (instrument-let)
                (begin
                  (eopl:printf
                    "entering body of proc ~s with env =~%"
                    var)
                  (pretty-print (env->list new-env)) 
                  (eopl:printf "store =~%")
                  (pretty-print (store->readable (get-store-as-list)))
                  (eopl:printf "~%"))
                  23)
              (value-of body new-env)))))))

  (define store->readable
    (lambda (l)
      (map
        (lambda (p)
          (list
            (car p)
            (expval->printable (cadr p))))
        l)))

  )