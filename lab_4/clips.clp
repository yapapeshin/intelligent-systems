;;; =============================================
;;; EXPERT SYSTEM: Tomato Disease Diagnosis (CLIPS)
;;; =============================================

(deftemplate symptom
  (slot name)
  (slot value (type SYMBOL) (allowed-symbols yes no unknown)))

(deftemplate disease
  (slot name)
  (slot probability (type FLOAT) (range 0.0 1.0))
  (slot treatment)
  (slot confidence (type INTEGER) (range 0 100)))

(deftemplate question
  (slot id)
  (slot text)
  (slot yes-rule)
  (slot no-rule))

;; База знаний: Симптомы заболеваний томатов
(deffacts initial-facts
  (symptom (name yellow-leaves) (value unknown))
  (symptom (name brown-spots) (value unknown))
  (symptom (name white-mold) (value unknown))
  (symptom (name wilting) (value unknown))
  (symptom (name curling-leaves) (value unknown))
  (symptom (name stunted-growth) (value unknown))
  (symptom (name black-stems) (value unknown))
  
  ;; Заболевания и их симптомы
  (disease-pattern late-blight 
    (symptom yellow-leaves yes) 
    (symptom brown-spots yes)
    (symptom white-mold yes))
  
  (disease-pattern early-blight
    (symptom brown-spots yes)
    (symptom yellow-leaves yes)
    (symptom curling-leaves yes))
  
  (disease-pattern fusarium-wilt
    (symptom wilting yes)
    (symptom yellow-leaves yes)
    (symptom stunted-growth yes))
  
  (disease-pattern bacterial-spot
    (symptom black-stems yes)
    (symptom wilting yes))
  
  ;; Лечения
  (treatment late-blight "1. Remove infected leaves\n2. Apply copper-based fungicide\n3. Improve air circulation")
  (treatment early-blight "1. Use fungicidal spray\n2. Water at soil level\n3. Remove affected plants")
  (treatment fusarium-wilt "1. Use resistant varieties\n2. Solarize soil\n3. Crop rotation")
  (treatment bacterial-spot "1. Apply copper bactericide\n2. Avoid overhead watering\n3. Disinfect tools")
)

;; Правила диагностики
(defrule ask-yellow-leaves
  (initial-fact)
  (symptom (name yellow-leaves) (value unknown))
  =>
  (printout t "Есть ли желтые листья на растениях? (yes/no): ")
  (bind ?answer (read))
  (assert (symptom (name yellow-leaves) (value ?answer))))

(defrule ask-brown-spots
  (symptom (name yellow-leaves) (value yes))
  (symptom (name brown-spots) (value unknown))
  =>
  (printout t "Есть ли коричневые пятна на листьях? (yes/no): ")
  (bind ?answer (read))
  (assert (symptom (name brown-spots) (value ?answer))))

(defrule diagnose-late-blight
  (symptom (name yellow-leaves) (value yes))
  (symptom (name brown-spots) (value yes))
  (symptom (name white-mold) (value yes))
  =>
  (assert (disease 
    (name "Late Blight") 
    (probability 0.95) 
    (treatment "Remove infected leaves, apply copper fungicide")
    (confidence 90))))

(defrule diagnose-early-blight
  (symptom (name yellow-leaves) (value yes))
  (symptom (name brown-spots) (value yes))
  (symptom (name curling-leaves) (value yes))
  (symptom (name white-mold) (value no))
  =>
  (assert (disease 
    (name "Early Blight") 
    (probability 0.85) 
    (treatment "Use fungicidal spray, water at soil level")
    (confidence 80))))

(defrule diagnose-fusarium-wilt
  (symptom (name wilting) (value yes))
  (symptom (name yellow-leaves) (value yes))
  (symptom (name stunted-growth) (value yes))
  =>
  (assert (disease 
    (name "Fusarium Wilt") 
    (probability 0.90) 
    (treatment "Use resistant varieties, solarize soil")
    (confidence 85))))

(defrule display-diagnosis
  (disease (name ?name) (probability ?prob) (treatment ?treat) (confidence ?conf))
  =>
  (printout t crlf "========== DIAGNOSIS ==========" crlf)
  (printout t "Disease: " ?name crlf)
  (printout t "Probability: " ?prob crlf)
  (printout t "Confidence: " ?conf "%" crlf)
  (printout t "Treatment: " ?treat crlf)
  (printout t "===============================" crlf))

(defrule no-disease-found
  (not (disease))
  =>
  (printout t "Не удалось определить заболевание. Проверьте другие симптомы." crlf))

;; Главная функция
(defrule start-diagnosis
  (initial-fact)
  =>
  (printout t "======== TOMATO DISEASE DIAGNOSIS ========" crlf)
  (printout t "Answer questions about symptoms (yes/no)" crlf))

(run)