// =============================================
// EXPERT SYSTEM: Tomato Disease Diagnosis (Drools)
// =============================================

// POJO классы
public class Symptom {
    private String name;
    private String value; // "YES", "NO", "UNKNOWN"
    
    // конструкторы, геттеры, сеттеры
}

public class Disease {
    private String name;
    private double probability;
    private String treatment;
    private int confidence;
    
    // конструкторы, геттеры, сеттеры
}

// Файл правил: tomato-diagnosis.drl
/*
package com.expert.tomato;

import com.expert.tomato.Symptom;
import com.expert.tomato.Disease;

// Правило 1: Фитофтороз (Late Blight)
rule "Late Blight Diagnosis"
    when
        $s1: Symptom(name == "yellowLeaves", value == "YES")
        $s2: Symptom(name == "brownSpots", value == "YES")
        $s3: Symptom(name == "whiteMold", value == "YES")
    then
        Disease disease = new Disease();
        disease.setName("Late Blight");
        disease.setProbability(0.95);
        disease.setTreatment("1. Remove infected leaves\n2. Apply copper fungicide\n3. Improve air circulation");
        disease.setConfidence(90);
        insert(disease);
        System.out.println("Diagnosed: Late Blight (95% probability)");
end

// Правило 2: Альтернариоз (Early Blight)
rule "Early Blight Diagnosis"
    when
        $s1: Symptom(name == "yellowLeaves", value == "YES")
        $s2: Symptom(name == "brownSpots", value == "YES")
        $s3: Symptom(name == "curlingLeaves", value == "YES")
        $s4: Symptom(name == "whiteMold", value == "NO")
    then
        Disease disease = new Disease();
        disease.setName("Early Blight");
        disease.setProbability(0.85);
        disease.setTreatment("1. Use fungicidal spray\n2. Water at soil level\n3. Remove affected plants");
        disease.setConfidence(80);
        insert(disease);
end

// Правило 3: Фузариозное увядание
rule "Fusarium Wilt Diagnosis"
    when
        $s1: Symptom(name == "wilting", value == "YES")
        $s2: Symptom(name == "yellowLeaves", value == "YES")
        $s3: Symptom(name == "stuntedGrowth", value == "YES")
    then
        Disease disease = new Disease();
        disease.setName("Fusarium Wilt");
        disease.setProbability(0.90);
        disease.setTreatment("1. Use resistant varieties\n2. Solarize soil\n3. Crop rotation");
        disease.setConfidence(85);
        insert(disease);
end

// Правило 4: Бактериальная пятнистость
rule "Bacterial Spot Diagnosis"
    when
        $s1: Symptom(name == "blackStems", value == "YES")
        $s2: Symptom(name == "wilting", value == "YES")
    then
        Disease disease = new Disease();
        disease.setName("Bacterial Spot");
        disease.setProbability(0.75);
        disease.setTreatment("1. Apply copper bactericide\n2. Avoid overhead watering\n3. Disinfect tools");
        disease.setConfidence(70);
        insert(disease);
end

// Правило 5: Вывод диагноза
rule "Display Diagnosis"
    when
        $d: Disease()
    then
        System.out.println("\n========== DIAGNOSIS ==========");
        System.out.println("Disease: " + $d.getName());
        System.out.println("Probability: " + $d.getProbability());
        System.out.println("Confidence: " + $d.getConfidence() + "%");
        System.out.println("Treatment: " + $d.getTreatment());
        System.out.println("===============================");
end

// Правило 6: Если болезнь не найдена
rule "No Disease Found"
    when
        not Disease()
    then
        System.out.println("No specific disease identified. Check general plant health.");
end
*/

// Основной класс приложения
public class TomatoDiagnosisSystem {
    public static void main(String[] args) {
        try {
            // Инициализация Drools
            KieServices ks = KieServices.Factory.get();
            KieContainer kc = ks.getKieClasspathContainer();
            KieSession ksession = kc.newKieSession("TomatoDiagnosisSession");
            
            // Ввод симптомов от пользователя
            Scanner scanner = new Scanner(System.in);
            
            System.out.println("======== TOMATO DISEASE DIAGNOSIS ========");
            
            Symptom yellowLeaves = new Symptom("yellowLeaves", askSymptom("Yellow leaves?", scanner));
            Symptom brownSpots = new Symptom("brownSpots", askSymptom("Brown spots on leaves?", scanner));
            Symptom whiteMold = new Symptom("whiteMold", askSymptom("White mold on leaves?", scanner));
            Symptom wilting = new Symptom("wilting", askSymptom("Plant wilting?", scanner));
            Symptom curlingLeaves = new Symptom("curlingLeaves", askSymptom("Leaves curling?", scanner));
            
            // Добавление фактов в рабочую память
            ksession.insert(yellowLeaves);
            ksession.insert(brownSpots);
            ksession.insert(whiteMold);
            ksession.insert(wilting);
            ksession.insert(curlingLeaves);
            
            // Запуск правил
            ksession.fireAllRules();
            ksession.dispose();
            scanner.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private static String askSymptom(String question, Scanner scanner) {
        System.out.print(question + " (YES/NO): ");
        String answer = scanner.nextLine().toUpperCase();
        return answer.equals("YES") || answer.equals("NO") ? answer : "UNKNOWN";
    }
}