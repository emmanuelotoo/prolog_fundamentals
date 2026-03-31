/* ===========================================================
   Lesson 3: Execution Control — Cut, Fail, Negation as Failure
   Ertel Ch. 5, Section 5.3
   ===========================================================

   Prolog's depth-first search can be inefficient. This lesson
   covers mechanisms to control execution:
   - Cut (!) — prune the search tree
   - fail/0 — force backtracking
   - \+/1 — negation as failure
   - (Cond -> Then ; Else) — if-then-else

   EXAM: Cut semantics and negation as failure are among the
   most frequently tested Prolog topics.

   =========================================================== */


% ===========================================================
% PART 1: The Cut (!)
% ===========================================================
% The cut commits Prolog to the current clause choice.
% Once a cut is reached:
%   1. All choice points for goals to the LEFT of ! in the current
%      clause are discarded.
%   2. No alternative clauses for the current predicate are tried.
%
% EXAM: Know exactly what the cut prunes. It does NOT affect
% choice points created by goals AFTER the cut or in calling predicates.

% --- Example: max/3 without cut ---
max_v1(X, Y, X) :- X >= Y.
max_v1(X, Y, Y) :- X < Y.

% Problem: for ?- max_v1(3, 2, Z), Z > 10.
% After Z=3 fails Z>10, Prolog backtracks and tries clause 2 of max_v1,
% which will also fail. This backtracking is UNNECESSARY because if
% X >= Y succeeded, X < Y cannot succeed.

% --- max/3 with green cut ---
max_v2(X, Y, X) :- X >= Y, !.
max_v2(X, Y, Y) :- X < Y.

% The cut prevents trying clause 2 after clause 1 succeeds.
% This is a GREEN CUT: it does NOT change the set of solutions,
% only improves efficiency.

% --- max/3 with red cut ---
max_v3(X, Y, X) :- X >= Y, !.
max_v3(_, Y, Y).

% The cut is now essential for correctness. Without it, clause 2
% would match even when X >= Y (giving wrong results).
% This is a RED CUT: removing ! changes the program's behavior.

% EXAM: Green cut = optimization only. Red cut = required for correctness.
%   ?- max_v3(3, 5, X).     --> X = 5  (correct)
%   Without cut, max_v3(3, 5, X) would also give X = 5 from clause 2...
%   but max_v3(5, 3, X) without cut would give X = 5 AND X = 3 (wrong!)


% ===========================================================
% PART 2: Cut — Another Example
% ===========================================================
% Classification with cut:

grade(Score, 'A') :- Score >= 90, !.
grade(Score, 'B') :- Score >= 80, !.
grade(Score, 'C') :- Score >= 70, !.
grade(Score, 'D') :- Score >= 60, !.
grade(_, 'F').

% Without cuts, grade(95, X) would return X='A', then on backtracking
% also X='B', X='C', X='D', X='F'. The cuts prevent this.
% These are RED cuts — removing them gives wrong extra solutions.

% ?- grade(85, X).   --> X = 'B'
% ?- grade(55, X).   --> X = 'F'


% ===========================================================
% PART 3: fail/0 — Forcing Backtracking
% ===========================================================
% fail/0 is a built-in that always fails, forcing backtracking.
% Combined with side effects (like write), it creates "failure-driven loops."

% From Ertel: print all children and their parents.
% (Using the family database from lesson_02)

child_fact(oscar, karen, frank).
child_fact(mary, karen, frank).
child_fact(eve, anne, oscar).
child_fact(henry, anne, oscar).
child_fact(isolde, anne, oscar).
child_fact(clyde, mary, oscarb).

print_all_children :-
    child_fact(X, Y, Z),
    write(X), write(' is a child of '),
    write(Y), write(' and '), write(Z), write('.'), nl,
    fail.
print_all_children.   % This clause succeeds after fail exhausts all solutions.

% ?- print_all_children.
% oscar is a child of karen and frank.
% mary is a child of karen and frank.
% eve is a child of anne and oscar.
% henry is a child of anne and oscar.
% isolde is a child of anne and oscar.
% clyde is a child of mary and oscarb.
% true.

% Without the second clause "print_all_children.", the predicate would
% return false after printing everything.
% Without "fail", only the FIRST child would be printed (then succeed).

% EXAM: Understand the fail-driven loop pattern:
%   generator, side_effect, fail.
%   predicate.   % catch-all to succeed


% ===========================================================
% PART 4: Negation as Failure (\+)
% ===========================================================
% \+ Goal succeeds if Goal CANNOT be proved.
% This is NOT true logical negation — it is based on the
% Closed World Assumption: anything not provable is assumed false.

% EXAM: negation as failure. If Prolog answers "false" (or "No"),
% it means the query cannot be proved, NOT that its negation is proved.

likes(alice, cats).
likes(bob, dogs).

dislikes_cats(X) :- \+ likes(X, cats).

% ?- dislikes_cats(bob).    --> true  (bob doesn't provably like cats)
% ?- dislikes_cats(alice).  --> false (alice does like cats)

% DANGER with unbound variables:
% ?- dislikes_cats(X).      --> false!
%
% Why? \+ likes(X, cats) tries likes(X, cats), which succeeds with
% X = alice. So \+ succeeds when its argument fails, but likes(X, cats)
% SUCCEEDED, so \+ fails. Prolog does NOT try other bindings for X.

% EXAM: \+ with unbound variables is a classic pitfall.
% Rule of thumb: ensure variables in \+ are bound BEFORE the call.

safe_dislikes_cats(X) :- likes(X, _), \+ likes(X, cats).
% Now X is bound by likes(X, _) before \+ is evaluated.
% ?- safe_dislikes_cats(X).  --> X = bob


% ===========================================================
% PART 5: If-Then-Else
% ===========================================================
% Prolog's if-then-else: (Condition -> Then ; Else)

max_v4(X, Y, Max) :-
    ( X >= Y -> Max = X ; Max = Y ).

% Equivalent to the cut version but arguably clearer.
% ?- max_v4(3, 5, M).  --> M = 5


% ===========================================================
% PART 6: The cut-fail idiom (explicit negation)
% ===========================================================
% Before \+ existed, negation was written as:

my_not(Goal) :- Goal, !, fail.
my_not(_).

% If Goal succeeds, cut commits and fail makes my_not fail.
% If Goal fails, the second clause succeeds.
% This is exactly what \+ does internally.


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 3.1 (Ertel Ex 5.5): Write as short a Prolog program as
% possible that outputs 1024 ones.
% Hint: 1024 = 2^10. Think recursively, or use between/3 with fail.

% Your code here:
% print_ones :- ...


% Exercise 3.2: What does this program output?
%   a(X, Y) :- X > 0, !, Y is X.
%   a(_, 0).
%   ?- a(3, Y), write(Y), nl, fail.
%   ?- a(-2, Y), write(Y), nl, fail.
% Write your prediction as a comment, then verify.


% Exercise 3.3: Rewrite grade/2 using (Cond -> Then ; Else) instead
% of cuts. Call it grade_ite/2.

% Your code here:
% grade_ite(Score, Grade) :- ...


% Exercise 3.4: Explain why this query behaves unexpectedly:
%   ?- \+ X = a.
% What does it return? Why?


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 3.1: Print 1024 ones.
% Method 1: Using between/3 and fail (shortest)
print_ones :-
    between(1, 1024, _),
    write(1),
    fail.
print_ones.

% Method 2: Recursive doubling (elegant, uses 2^10 = 1024)
print_n_ones(0) :- !.
print_n_ones(N) :- N > 0, write(1), N1 is N - 1, print_n_ones(N1).

print_1024 :- print_n_ones(1024).

% Method 3: Recursive doubling approach
double_print(0) :- write(1).
double_print(N) :- N > 0, N1 is N - 1, double_print(N1), double_print(N1).
% ?- double_print(10). prints 2^10 = 1024 ones

% Solution 3.2:
%   ?- a(3, Y), write(Y), nl, fail.
%   Output: 3
%   Explanation: a(3, Y) matches clause 1 (3 > 0, cut, Y = 3).
%   The cut prevents clause 2 from being tried. write(3), nl, then fail.
%   No more alternatives -> false.
%
%   ?- a(-2, Y), write(Y), nl, fail.
%   Output: 0
%   Explanation: a(-2, Y) tries clause 1, but -2 > 0 fails. No cut reached.
%   Clause 2: a(_, 0) matches, Y = 0. write(0), nl, then fail -> false.

% Solution 3.3:
grade_ite(Score, Grade) :-
    ( Score >= 90 -> Grade = 'A'
    ; Score >= 80 -> Grade = 'B'
    ; Score >= 70 -> Grade = 'C'
    ; Score >= 60 -> Grade = 'D'
    ; Grade = 'F'
    ).

% Solution 3.4:
%   ?- \+ X = a.
%   Returns: false
%
%   Why: \+ tries to prove X = a. Since X is unbound, X = a SUCCEEDS
%   (unification binds X to a). Since the goal succeeded, \+ fails.
%   This is counterintuitive — "not X = a" fails because X CAN be a.
%   This is a key consequence of negation as failure with unbound variables.
