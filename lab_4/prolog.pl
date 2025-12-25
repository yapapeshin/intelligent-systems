%% =============================================
%% EXPERT SYSTEM: Tomato Disease Diagnosis (Prolog)
%% =============================================

% База знаний: Факты о заболеваниях
% Формат: disease(Name, Symptoms, Probability, Treatment)

disease('Late Blight',
        [yellow_leaves, brown_spots, white_mold, rapid_spread],
        0.95,
        ['Remove infected leaves immediately',
         'Apply copper-based fungicide',
         'Improve air circulation',
         'Avoid overhead watering']).

disease('Early Blight',
        [brown_spots, yellow_leaves, concentric_rings, curling_leaves],
        0.85,
        ['Use fungicidal spray',
         'Water at soil level',
         'Remove affected leaves',
         'Apply neem oil']).

disease('Fusarium Wilt',
        [wilting, yellow_leaves, stunted_growth, brown_stems],
        0.90,
        ['Use resistant tomato varieties',
         'Solarize soil before planting',
         'Practice crop rotation',
         'Remove infected plants']).

disease('Bacterial Spot',
        [black_stems, wilting, water_soaked_spots, leaf_drop],
        0.75,
        ['Apply copper bactericide',
         'Avoid working with wet plants',
         'Disinfect tools regularly',
         'Use pathogen-free seeds']).

disease('Powdery Mildew',
        [white_powder, yellow_leaves, stunted_growth],
        0.70,
        ['Apply sulfur-based fungicide',
         'Improve air circulation',
         'Reduce humidity',
         'Remove affected leaves']).

% Правила диагностики
has_disease(Plant, Disease, Probability, Treatment) :-
    disease(Disease, Symptoms, BaseProb, Treatment),
    findall(Symptom, (member(Symptom, Symptoms), has_symptom(Plant, Symptom)), PresentSymptoms),
    length(Symptoms, TotalSymptoms),
    length(PresentSymptoms, PresentCount),
    Probability is BaseProb * (PresentCount / TotalSymptoms),
    Probability > 0.5.  % Минимальный порог вероятности

% Вспомогательные предикаты
has_symptom(tomato1, yellow_leaves).
has_symptom(tomato1, brown_spots).
has_symptom(tomato1, white_mold).
has_symptom(tomato1, rapid_spread).

has_symptom(tomato2, wilting).
has_symptom(tomato2, yellow_leaves).
has_symptom(tomato2, stunted_growth).

% Предикат для интерактивной диагностики
diagnose :-
    write('=== Tomato Disease Diagnosis System ==='), nl,
    write('Answer questions with yes. or no.'), nl, nl,
    
    % Вопросы о симптомах
    ask_symptom('Yellow leaves? ', Yellow),
    ask_symptom('Brown spots on leaves? ', BrownSpots),
    ask_symptom('White mold/powder? ', WhiteMold),
    ask_symptom('Plant wilting? ', Wilting),
    ask_symptom('Leaves curling? ', Curling),
    ask_symptom('Stunted growth? ', Stunted),
    ask_symptom('Black stems? ', BlackStems),
    
    nl, write('Analyzing symptoms...'), nl, nl,
    
    % Сбор симптомов
    findall(Symptom, (
        (Yellow = yes, Symptom = yellow_leaves);
        (BrownSpots = yes, Symptom = brown_spots);
        (WhiteMold = yes, Symptom = white_mold);
        (Wilting = yes, Symptom = wilting);
        (Curling = yes, Symptom = curling_leaves);
        (Stunted = yes, Symptom = stunted_growth);
        (BlackStems = yes, Symptom = black_stems)
    ), Symptoms),
    
    % Поиск подходящих заболеваний
    findall([Disease, Prob, Treatment], (
        disease(Disease, DiseaseSymptoms, BaseProb, Treatment),
        intersection(Symptoms, DiseaseSymptoms, Common),
        length(Common, CommonCount),
        length(DiseaseSymptoms, TotalSymptoms),
        Prob is (CommonCount / TotalSymptoms) * BaseProb,
        Prob > 0.4
    ), Diseases),
    
    % Сортировка по вероятности
    predsort(compare_probabilities, Diseases, SortedDiseases),
    
    % Вывод результатов
    (   SortedDiseases = []
    ->  write('No specific disease identified.'), nl,
        write('General recommendations:'), nl,
        write('1. Ensure proper watering'), nl,
        write('2. Check soil nutrients'), nl,
        write('3. Monitor plant health')
    ;   write('Possible diagnoses (sorted by probability):'), nl, nl,
        display_diagnoses(SortedDiseases)
    ).

% Предикат для сравнения вероятностей
compare_probabilities(>, [_, Prob1, _], [_, Prob2, _]) :- Prob1 < Prob2.
compare_probabilities(<, [_, Prob1, _], [_, Prob2, _]) :- Prob1 > Prob2.

% Предикат для отображения диагнозов
display_diagnoses([]).
display_diagnoses([[Disease, Prob, Treatment]|Rest]) :-
    format('Disease: ~w', [Disease]), nl,
    format('Probability: ~2f%', [Prob]), nl,
    write('Recommended treatment:'), nl,
    display_treatment(Treatment),
    nl, write('---'), nl, nl,
    display_diagnoses(Rest).

display_treatment([]).
display_treatment([Action|Rest]) :-
    write('- '), write(Action), nl,
    display_treatment(Rest).

% Предикат для запроса симптомов
ask_symptom(Question, Answer) :-
    write(Question),
    read(Response),
    (   Response = yes
    ->  Answer = yes
    ;   Answer = no
    ).

% Предикат для тестирования конкретного растения
test_plant(PlantName) :-
    writef('Diagnosing %w...\n', [PlantName]),
    findall([Disease, Prob, Treatment], 
            has_disease(PlantName, Disease, Prob, Treatment), 
            Results),
    (   Results = []
    ->  write('No diagnosis found for this plant.')
    ;   write('Possible diseases:'), nl,
        display_results(Results)
    ).

display_results([]).
display_results([[Disease, Prob, Treatment]|Rest]) :-
    format('~w (~2f probability)', [Disease, Prob]), nl,
    write('Treatment:'), nl,
    display_treatment(Treatment), nl,
    display_results(Rest).

% Примеры запросов:
% ?- diagnose.                    % Интерактивная диагностика
% ?- test_plant(tomato1).         % Тест конкретного растения
% ?- has_disease(tomato1, D, P, T). % Поиск всех возможных заболеваний