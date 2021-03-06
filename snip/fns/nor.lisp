;;; -*- Mode: Lisp; Syntax: Common-Lisp; Package: SNIP; Base: 10 -*-

;; Copyright (C) 1984--2007
;; Research Foundation of State University of New York

;; Version: $Id: nor.lisp,v 1.3 2007/08/21 01:54:40 mwk3 Exp $

;; This file is part of SNePS.

;; $BEGIN LICENSE$

;; 
;; The contents of this file are subject to the University at
;; Buffalo Public License Version 1.0 (the "License"); you may
;; not use this file except in compliance with the License. You
;; may obtain a copy of the License at http://www.cse.buffalo.
;; edu/sneps/Downloads/ubpl.pdf.
;; 
;; Software distributed under the License is distributed on an
;; "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
;; or implied. See the License for the specific language gov
;; erning rights and limitations under the License.
;; 
;; The Original Code is SNePS 2.7.
;; 
;; The Initial Developer of the Original Code is Research Foun
;; dation of State University of New York, on behalf of Univer
;; sity at Buffalo.
;; 
;; Portions created by the Initial Developer are Copyright (C)
;; 2007 Research Foundation of State University of New York, on
;; behalf of University at Buffalo. All Rights Reserved.
;; 
;;  
;; 
;; 


;; $END LICENSE$


(in-package :snip)


;  nor functions
;
(defun rule-handler.nor (ant-report cqch)
  ;; if the antecedents have the same set of variables,
  ;; use S-indexing, otherwise use linear ruiset handling    
  (do.set (rui (if (or (null (ants.cqch cqch))
		       (is-all-pat-same-vars (ants.cqch cqch)))
		   (get-rule-use-info-sindexing ant-report cqch)
		 (get-rule-use-info ant-report cqch))
	       t)
	  (when (eql (sign.rep ant-report) 'pos)
	    ;; Removed the case when (sign.rep ant-report) was neg
	    ;;   which reported "~%It is the case that"...
	    ;; It doesn't seem to make sense that a nor rule
	    ;;    could conclude that something is the case. scs/flj 6/27/04
	    (let ((restr (make.restr (subst.rui rui)))
		  (ch (channel.cqch cqch)))
	      (unless-remarkedp.rui
	       rui (remark '"~%I know it is not the case that"
			   (makeone.ns (destination.ch ch))
			   restr))
	      (send-reports
	       (makeone.repset
		(make.rep
		 (restrict.sbst (subst.rui rui)
				(freevars.n (destination.ch ch)))
		 (compute-new-support.nor ch rui ant-report)
		 'neg
		 *node*
		 nil
		 (context.ch ch)
		 ))
	       ch)))))


; =============================================================================
;

(defun usability-test.nor (sign)
  (declare (ignore sign))
  (or (isnew.ns (quantified-vars.n *NODE*))
      (not (isnew.ns (nodeset.n *NODE* 'sneps::forall)))))


;
;
; =============================================================================
;
; compute-new-support.nor
; -------------------------
;
;       arguments     : ch     - <channel>
;                       rui    - <rule-use-info>
;                       antrep - <report>
;
;       returns       : <support>
;
;       description   : Computes a new support based on:
;                        1- the support of the rule node if it is asserted;
;                        2- the support of the instances (of the rule) which
;                           are asserted in the 'ch' context and has the 
;                           appropriate substitution. 
;
;
;
;                                        written :  cpf/njm  10/25/88
;                                        modified: 
;
;
(defun compute-new-support.nor (ch rui antrep)
  (let ((crntct (context.ch ch))
	(newsupport (new.sup))
	(freevars (freevars.n *NODE*)))
    (if (and (isassert.n *NODE*)
    	     (eql (cardinality.ns (nodeset.n *NODE* 'sneps:arg)) 1)
	     (eq (sign.rep antrep) 'POS))
	(setq newsupport (support.rep antrep))
	(setq newsupport (change-tag-support (support.rep antrep) 'sneps:HYP 'sneps:DER)))
    (when *KNOWN-INSTANCES*
      (do.set (inst *KNOWN-INSTANCES*)
	(let* ((instnode (match::applysubst *NODE* (subst.inst inst)))
	       (supinstnode (filter.sup (sneps:node-asupport instnode) crntct)))
	  (when (and (not (isnew.sup supinstnode))
		     (match:issubset.sbst (restrict.sbst (subst.rui rui) freevars)
					  (restrict.sbst (subst.inst inst) freevars)))
	    (setq newsupport (merge.sup newsupport
					(compute-new-support1.nor (support.rep antrep)
								  supinstnode)))))))
    newsupport))
;
; =============================================================================
;
; compute-new-support1.nor
; -----------------------
;
;       arguments     : sup  - <support>
;                       supr - <support>
;
;       returns       : <support>
;
;       description   : receives as arguments:
;                        'sup'  -- the support of the report
;                        'supr' -- the support of the rule node
;                       Computes a new support based on 'sup' and on the support
;                       of the `supr'.
;
;
;
;                                        written :  cpf/njm  10/25/88
;                                        modified: 
;
;
(defun compute-new-support1.nor (sup supr)
  (let ((newsupport (new.sup)))
    (do* ((s1 supr (others.sup s1))
	  (ot1 (ot.sup s1) (ot.sup s1))
	  (cts1 (ctset.sup s1) (ctset.sup s1)))
	 ((isnew.sup s1) newsupport)
      (dolist (ct1 cts1)
	(do* ((s2 sup (others.sup s2))
	      (ot2 (ot.sup s2) (ot.sup s2))
	      (cts2 (ctset.sup s2) (ctset.sup s2)))
	     ((isnew.sup s2) t)
	  (dolist (ct2 cts2)
	  	(setq telprops (sneps:union.ns (sneps:context-telprops ct1) (sneps:context-telprops ct2)))
	    (setq newsupport
		  (insert.sup (combine-ots ot1 ot2)
			      (fullbuildcontext (new.ns) (make.cts ct1 ct2) (new.ns) telprops)
			      newsupport))))))))


; 
;
; =============================================================================
;
; change-tag-support
; ------------------
;
;       arguments     : sup - <support>
;                       ot1 - <origin tag>
;                       ot2 - <origin tag>			
;                       
;       returns       : <support>
;
;       description   : receives as arguments:
;                        'sup'  -- the support of the rule node
;                       Changes the tags of support 'sup'from 'ot1' to 'ot2'.
;
;
;
;                                        written :  njm  11/20/88
;                                        modified:  nea 7/15
;
;
(defun change-tag-support (sup ot1 ot2)
  (let ((newsupport (new.sup)))
    (do* ((s sup (others.sup s))
	  (ot (ot.sup s) (ot.sup s))
	  (cts (ctset.sup s) (ctset.sup s)))
	 ((isnew.sup s) newsupport)
      (dolist (ct cts)
	(setq newsupport
	      (insert.sup (if (equal ot ot1) ot2 ot)
			  ct
			  newsupport))))))








    
    




