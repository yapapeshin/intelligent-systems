% member/2 - проверка принадлежности элемента
% (часто встроен)
member(X, [X|_]).
member(X, [_|Tail]) :- member(X, Tail).

% append/3 - конкатенация списков
% (часто встроен)
append([], List, List).
append([Head|Tail], List, [Head|Rest]) :-
    append(Tail, List, Rest).

% length/2 - длина списка
% (часто встроен)
length([], 0).
length([_|Tail], N) :-
    length(Tail, N1),
    N is N1 + 1.



% 1. last/2 - последний элемент списка
last([X], X).
last([_|Tail], Last) :- last(Tail, Last).

% 2. reverse/2 - обращение списка
reverse(List, Reversed) :-
    reverse_acc(List, [], Reversed).

reverse_acc([], Acc, Acc).
reverse_acc([Head|Tail], Acc, Reversed) :-
    reverse_acc(Tail, [Head|Acc], Reversed).

% 3. prefix/2 - проверка префикса
prefix(Prefix, List) :-
    append(Prefix, _, List).

% 4. suffix/2 - проверка суффикса
suffix(Suffix, List) :-
    append(_, Suffix, List).

% 5. sublist/2 - проверка подсписка
sublist(Sublist, List) :-
    prefix(Prefix, List),
    append(Sublist, _, Prefix).

% 6. remove/3 - удаление элемента
remove(X, [X|Tail], Tail).
remove(X, [Head|Tail], [Head|Rest]) :-
    remove(X, Tail, Rest).

% 7. delete_all/3 - удаление всех вхождений
delete_all(_, [], []).
delete_all(X, [X|Tail], Result) :-
    delete_all(X, Tail, Result).
delete_all(X, [Head|Tail], [Head|Result]) :-
    X \= Head,
    delete_all(X, Tail, Result).

% 8. replace/4 - замена элемента
replace(_, _, [], []).
replace(Old, New, [Old|Tail], [New|Result]) :-
    replace(Old, New, Tail, Result).
replace(Old, New, [Head|Tail], [Head|Result]) :-
    Old \= Head,
    replace(Old, New, Tail, Result).

% 9. flatten/2 - сглаживание вложенных списков
flatten([], []).
flatten([Head|Tail], Flat) :-
    flatten(Head, FlatHead),
    flatten(Tail, FlatTail),
    append(FlatHead, FlatTail, Flat).
flatten(Element, [Element]) :-
    \+ is_list(Element).

is_list([]).
is_list([_|_]).

% 10. sum_list/2 - сумма элементов (для чисел)
sum_list([], 0).
sum_list([Head|Tail], Sum) :-
    sum_list(Tail, SumTail),
    Sum is Head + SumTail.

% 11. max_list/2 и min_list/2 - максимальный и минимальный элемент
max_list([X], X).
max_list([Head|Tail], Max) :-
    max_list(Tail, MaxTail),
    (Head > MaxTail -> Max = Head; Max = MaxTail).

min_list([X], X).
min_list([Head|Tail], Min) :-
    min_list(Tail, MinTail),
    (Head < MinTail -> Min = Head; Min = MinTail).





% 12. map/3 - применение функции к каждому элементу
map(_, [], []).
map(Predicate, [Head|Tail], [ResultHead|ResultTail]) :-
    call(Predicate, Head, ResultHead),
    map(Predicate, Tail, ResultTail).

% 13. filter/3 - фильтрация по условию
filter(_, [], []).
filter(Predicate, [Head|Tail], [Head|Filtered]) :-
    call(Predicate, Head),
    filter(Predicate, Tail, Filtered).
filter(Predicate, [Head|Tail], Filtered) :-
    \+ call(Predicate, Head),
    filter(Predicate, Tail, Filtered).

% 14. foldl/4 и foldr/4 - свертка
foldl(_, [], Acc, Acc).
foldl(Predicate, [Head|Tail], Acc, Result) :-
    call(Predicate, Head, Acc, NewAcc),
    foldl(Predicate, Tail, NewAcc, Result).

foldr(_, [], Acc, Acc).
foldr(Predicate, [Head|Tail], Acc, Result) :-
    foldr(Predicate, Tail, Acc, TempResult),
    call(Predicate, Head, TempResult, Result).

% 15. all/2 и any/2 - проверка всех/хотя бы одного элемента
all(Predicate, List) :-
    \+ (member(Element, List), \+ call(Predicate, Element)).

any(Predicate, List) :-
    member(Element, List),
    call(Predicate, Element).





% 16. unique/2 - удаление дубликатов
unique([], []).
unique([Head|Tail], [Head|UniqueTail]) :-
    delete_all(Head, Tail, WithoutHead),
    unique(WithoutHead, UniqueTail).

% 17. split/4 - разделение списка по условию
split(_, [], [], []).
split(Predicate, [Head|Tail], [Head|True], False) :-
    call(Predicate, Head),
    split(Predicate, Tail, True, False).
split(Predicate, [Head|Tail], True, [Head|False]) :-
    \+ call(Predicate, Head),
    split(Predicate, Tail, True, False).

% 18. zip/3 - объединение двух списков в список пар
zip([], [], []).
zip([H1|T1], [H2|T2], [(H1, H2)|T3]) :-
    zip(T1, T2, T3).

% 19. take/3 и drop/3 - взять/отбросить N элементов
take(0, _, []).
take(N, [Head|Tail], [Head|Taken]) :-
    N > 0,
    N1 is N - 1,
    take(N1, Tail, Taken).

drop(0, List, List).
drop(N, [_|Tail], Dropped) :-
    N > 0,
    N1 is N - 1,
    drop(N1, Tail, Dropped).

% 20. partition/4 - разделение на два списка по индексу
partition(N, List, Left, Right) :-
    take(N, List, Left),
    drop(N, List, Right).





% Пример 1: Использование map
double(X, Y) :- Y is X * 2.
% ?- map(double, [1,2,3,4], Result). -> Result = [2,4,6,8]

% Пример 2: Использование filter
even(X) :- 0 is X mod 2.
% ?- filter(even, [1,2,3,4,5,6], Result). -> Result = [2,4,6]

% Пример 3: Использование foldl
sum_acc(Element, Acc, NewAcc) :- NewAcc is Acc + Element.
% ?- foldl(sum_acc, [1,2,3,4], 0, Sum). -> Sum = 10

% Пример 4: Комбинирование предикатов
sum_of_squares(List, Sum) :-
    map(square, List, Squares),
    sum_list(Squares, Sum).

square(X, Y) :- Y is X * X.
% ?- sum_of_squares([1,2,3], Result). -> Result = 14








% 21. count/3 - подсчет элементов, удовлетворяющих условию
count(_, [], 0).
count(Predicate, [Head|Tail], Count) :-
    count(Predicate, Tail, TailCount),
    (call(Predicate, Head) -> Count is TailCount + 1; Count = TailCount).

% 22. intersperse/3 - вставка элемента между элементами списка
intersperse(_, [], []).
intersperse(_, [X], [X]).
intersperse(Sep, [Head|Tail], [Head, Sep|Result]) :-
    intersperse(Sep, Tail, Result).

% 23. rotate/3 - циклический сдвиг
rotate(0, List, List).
rotate(N, List, Rotated) :-
    N > 0,
    append(Left, [Last], List),
    rotate(N1, [Last|Left], Rotated),
    N1 is N - 1.

% 24. permutations/2 - все перестановки
permutations([], []).
permutations(List, [Head|Perm]) :-
    select(Head, List, Rest),
    permutations(Rest, Perm).

select(X, [X|Tail], Tail).
select(X, [Head|Tail], [Head|Rest]) :-
    select(X, Tail, Rest).