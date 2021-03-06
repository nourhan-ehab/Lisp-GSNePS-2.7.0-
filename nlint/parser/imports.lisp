;;; -*- Mode: Lisp; Syntax: Common-Lisp; Package: PARSER; Base: 10 -*-

;; Copyright (C) 1984--2007 Research Foundation of 
;;                          State University of New York

;; Version: $Id: imports.lisp,v 1.3 2007/08/21 01:54:22 mwk3 Exp $

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


(in-package :parser)


;;;   Import the following symbols into the PARSER package from
;;;      the SNePS package.

(import '(sneps:|#| sneps:% sneps:$ sneps:^
		  sneps:define
		  ; sneps:test sneps::using-reader-macro-characters
	          sneps:defsnepscom
		  snip:deduce snip:add
		  englex:get-lexical-feature englex:first-atom englex:flistify
		  englex:lookup englex:lookup-lexical-feature englex:*lexicon*
		  englex:verbize
		  englex:wordize
		  snepsul:s))

(shadowing-import '(sneps::find sneps:|*| sneps:!))

(shadow 'lisp:getf)

(import 'sneps:build-namestring)  ;; for acl6 (FLJ)




    
    




