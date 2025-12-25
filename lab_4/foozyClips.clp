;;; =============================================
;;; FUZZY EXPERT SYSTEM: Tomato Disease Diagnosis
;;; =============================================

;; Нечеткие множества для степени проявления симптомов
(deftemplate symptom-fuzzy
  (slot name)
  (slot severity (type FUZZY-VALUE severe moderate mild none)))

;; Нечеткие лингвистические переменные
(deffunction fuzzy-severity::severity (?value)
  (bind ?result (create$))
  (if (<= ?value 0.3) then
    (bind ?result (create$ none 1.0))
  else if (<= ?value 0.6) then
    (bind ?result (create$ mild 1.0))
  else if (<= ?value 0.8) then
    (bind ?result (create$ moderate 1.0))
  else
    (bind ?result (create$ severe 1.0))
  )
  ?result)

;; Факты о симптомах с нечеткими значениями
(deffacts fuzzy-symptoms
  (symptom-fuzzy (name yellow-leaves) (severity (fuzzy-severity 0.7)))
  (symptom-fuzzy (name brown-spots) (severity (fuzzy-severity 0.8)))
  (symptom-fuzzy (name wilting) (severity (fuzzy-severity 0.5)))
  (symptom-fuzzy (name white-mold) (severity (fuzzy-severity 0.9)))
)

;; Нечеткие правила диагностики
(defrule fuzzy-late-blight
  (symptom-fuzzy (name yellow-leaves) (severity ?s1&:(> (fuzzy-value ?s1) 0.6)))
  (symptom-fuzzy (name brown-spots) (severity ?s2&:(> (fuzzy-value ?s2) 0.7)))
  (symptom-fuzzy (name white-mold) (severity ?s3&:(> (fuzzy-value ?s3) 0.8)))
  =>
  (assert (disease 
    (name "Late Blight (Fuzzy)") 
    (probability (fuzzy-calc-avg ?s1 ?s2 ?s3))
    (confidence (fuzzy-to-confidence (fuzzy-calc-avg ?s1 ?s2 ?s3))))))

(defrule fuzzy-early-blight
  (symptom-fuzzy (name yellow-leaves) (severity ?s1&:(> (fuzzy-value ?s1) 0.5)))
  (symptom-fuzzy (name brown-spots) (severity ?s2&:(> (fuzzy-value ?s2) 0.6)))
  (symptom-fuzzy (name curling-leaves) (severity ?s3&:(> (fuzzy-value ?s3) 0.4)))
  (symptom-fuzzy (name white-mold) (severity ?s4&:(< (fuzzy-value ?s4) 0.3)))
  =>
  (bind ?avg (fuzzy-calc-avg ?s1 ?s2 ?s3))
  (assert (disease 
    (name "Early Blight (Fuzzy)") 
    (probability ?avg)
    (confidence (fuzzy-to-confidence ?avg)))))

;; Вспомогательные функции для нечеткой логики
(deffunction fuzzy-calc-avg (?s1 ?s2 ?s3)
  (/ (+ (fuzzy-value ?s1) (fuzzy-value ?s2) (fuzzy-value ?s3)) 3.0))

(deffunction fuzzy-to-confidence (?prob)
  (bind ?conf (* ?prob 100))
  (if (> ?conf 100) then (bind ?conf 100))
  (if (< ?conf 0) then (bind ?conf 0))
  ?conf)

;; Правило для нечеткого вывода рекомендаций
(defrule fuzzy-treatment-recommendation
  (disease (name ?name) (probability ?prob) (confidence ?conf))
  =>
  (printout t crlf "========== FUZZY DIAGNOSIS ==========" crlf)
  (printout t "Disease: " ?name crlf)
  (printout t "Probability: " (format nil "%.2f" ?prob) crlf)
  (printout t "Confidence: " ?conf "%" crlf)
  
  ;; Нечеткие рекомендации лечения
  (if (>= ?prob 0.8) then
    (printout t "Recommendation: IMMEDIATE treatment required" crlf)
    (printout t "Suggested: Chemical fungicides + Removal of affected parts" crlf)
  else if (>= ?prob 0.6) then
    (printout t "Recommendation: Urgent treatment recommended" crlf)
    (printout t "Suggested: Organic fungicides + Improved conditions" crlf)
  else
    (printout t "Recommendation: Preventive measures suggested" crlf)
    (printout t "Suggested: Monitoring + General plant care" crlf)
  )
  (printout t "========================================" crlf))

;; Функция для нечеткого ввода симптомов
(deffunction input-fuzzy-symptom (?name ?question)
  (printout t ?question " (0-1, where 0=none, 1=severe): ")
  (bind ?value (read))
  (assert (symptom-fuzzy (name ?name) 
           (severity (fuzzy-severity ?value)))))

;; Основная функция диагностики
(defrule start-fuzzy-diagnosis
  (initial-fact)
  =>
  (printout t "======== FUZZY TOMATO DIAGNOSIS ========" crlf)
  (printout t "Rate symptom severity from 0 to 1" crlf crlf)
  
  (input-fuzzy-symptom yellow-leaves "Yellow leaves severity:")
  (input-fuzzy-symptom brown-spots "Brown spots severity:")
  (input-fuzzy-symptom white-mold "White mold severity:")
  (input-fuzzy-symptom wilting "Wilting severity:")
  (input-fuzzy-symptom curling-leaves "Leaf curling severity:")
  
  (printout t crlf "Processing fuzzy diagnosis..." crlf))

(run)