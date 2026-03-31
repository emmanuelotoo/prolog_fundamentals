/* ===========================================================
   Lesson 5: Self-Modifying Programs — Assert, Retract, Memoization
   Ertel Ch. 5, Section 5.5
   ===========================================================

   Prolog programs are interpreted (via the WAM), so they can be
   modified at runtime. This lesson covers:
   - assert/1, asserta/1, assertz/1 — add clauses
   - retract/1, retractall/1 — remove clauses
   - :- dynamic declaration
   - Memoization pattern with asserta
   - Fibonacci: naive (exponential) vs memoized (linear)

   EXAM: The memoization pattern with asserta is a classic exam topic.
   Know the complexity improvement and WHY asserta (not assertz).

   =========================================================== */


% ===========================================================
% PART 1: Dynamic Declarations
% ===========================================================
% In SWI-Prolog, predicates modified at runtime must be declared dynamic.
% Without this, assert/retract will throw an error.

:- dynamic counter/1.
:- dynamic fib_cache/2.
:- dynamic memo_descendant/2.


% ===========================================================
% PART 2: assert and retract
% ===========================================================
%   asserta(Clause) — add Clause at the BEGINNING of the database
%   assertz(Clause) — add Clause at the END of the database
%   assert(Clause)  — same as assertz (deprecated, use assertz)
%
%   retract(Clause)    — remove the FIRST matching clause
%   retractall(Head)   — remove ALL clauses whose head matches Head
%
% IMPORTANT: Asserted facts PERSIST across backtracking.
% If you assert something and then fail/backtrack, the fact remains!

% Example: a simple counter
counter(0).

increment :-
    retract(counter(N)),
    N1 is N + 1,
    asserta(counter(N1)).

% ?- counter(X).       --> X = 0
% ?- increment.        --> true
% ?- counter(X).       --> X = 1
% ?- increment, increment, increment.
% ?- counter(X).       --> X = 4


% ===========================================================
% PART 3: Fibonacci — Naive Recursive (Exponential)
% ===========================================================
% fib(0) = 1, fib(1) = 1, fib(n) = fib(n-1) + fib(n-2)

fib(0, 1).
fib(1, 1).
fib(N, R) :-
    N > 1,
    N1 is N - 1,
    N2 is N - 2,
    fib(N1, R1),
    fib(N2, R2),
    R is R1 + R2.

% EXAM: Complexity of naive fib.
%
% T(n) = T(n-1) + T(n-2) + O(1)
% This is the Fibonacci recurrence itself!  T(n) = O(phi^n) where phi ~ 1.618
% Exponential time — fib(30) makes ~2.7 million calls.
%
% Try:  ?- time(fib(20, R)).   --> ~21,000 inferences
%       ?- time(fib(30, R)).   --> ~2,700,000 inferences (slow!)


% ===========================================================
% PART 4: Fibonacci — Memoized with asserta (Linear)
% ===========================================================
% The idea: after computing fib(N, R), store it as a fact with asserta.
% Next time fib(N, _) is needed, the cached fact is found immediately.
% Using asserta (not assertz) puts the cached fact BEFORE the rules,
% so it's found first.

fib_memo(0, 1).
fib_memo(1, 1).
fib_memo(N, R) :-
    N > 1,
    N1 is N - 1,
    N2 is N - 2,
    fib_memo(N1, R1),
    fib_memo(N2, R2),
    R is R1 + R2,
    asserta(fib_memo(N, R)).   % <-- cache the result!

% EXAM: Why is this linear?
%
% The first call to fib_memo(N, R) computes fib for each value 0..N
% exactly once. After fib_memo(K, Rk) returns, asserta stores it.
% When fib_memo(K, _) is needed again, the cached fact is found in O(1).
% Total: O(n) calls, each doing O(1) work = O(n) overall.
%
% Try:  ?- time(fib_memo(30, R)).   --> ~90 inferences (vs 2.7M naive!)
%       ?- time(fib_memo(50, R)).   --> ~150 inferences
%
% EXAM: Why asserta and not assertz?
% asserta puts the fact at the BEGINNING. When Prolog looks up
% fib_memo(30, R), it finds the cached fact immediately, without
% first trying the recursive rule.

% EXAM: Second call is even faster!
% After ?- fib_memo(50, R). all values 0-50 are cached.
% A second call ?- fib_memo(50, R). does just 1 inference.

clear_fib_cache :-
    retractall(fib_cache(_, _)).


% ===========================================================
% PART 5: Memoized descendant (from Ertel Sect 5.5)
% ===========================================================
% Ertel shows how to cache derived descendant facts:
%
%   :- dynamic descendant/2.
%   descendant(X,Y) :- child(X,Y,Z), asserta(descendant(X,Y)).
%   descendant(X,Y) :- child(X,U,V), descendant(U,Y),
%                       asserta(descendant(X,Y)).
%
% After ?- descendant(clyde, karen), the facts
%   descendant(clyde, karen).
%   descendant(mary, karen).
% are added to the database, avoiding re-derivation.
%
% WARNING: assert/retract are EXTRA-LOGICAL — they have side effects
% that don't obey the logical semantics of Prolog. Use with care.


% ===========================================================
% PART 6: Self-modifying programs and genetic programming
% ===========================================================
% Since Prolog programs are data (clauses in the database), a program
% can modify its own rules, not just facts. This idea underlies
% "genetic programming" — evolving programs by random modification.
%
% In practice, random code changes rarely improve behavior because
% the space of senseless modifications is enormous. Systematic
% approaches (machine learning, Ch. 8 of Ertel) are more effective.


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 5.1 (Ertel Ex 5.8a): Implement fib/2 (done above).
% Verify: ?- fib(10, R). --> R = 89

% Exercise 5.2 (Ertel Ex 5.8b): Measure the runtime of fib/2 for
% N = 15, 20, 25, 30. Does the growth match O(phi^n)?
% Use: ?- time(fib(N, R)).
% Record inferences in comments.

% Exercise 5.3 (Ertel Ex 5.8c,d): The memoized version is above.
% Clear the cache with retractall(fib_memo(_, _)), then:
%   ?- time(fib_memo(30, R)).   % first call
%   ?- time(fib_memo(30, R)).   % second call (should be ~1 inference)
% Record both timings.

% Exercise 5.4 (Ertel Ex 5.8e): Why is fib_memo faster even on the
% FIRST call (right after starting Prolog)?
% Write your answer as a comment.

% Exercise 5.5: Write a memoized binomial coefficient predicate.
% binom(N, K, R) where R = C(N, K) = C(N-1, K-1) + C(N-1, K).
% Base cases: C(N, 0) = 1, C(N, N) = 1.

% Your code here:
% :- dynamic binom_cache/3.
% binom(N, 0, 1) :- ...
% binom(N, K, R) :- ...


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 5.2: Expected inference counts (approximate):
%   fib(15, _) :  ~  1,900 inferences
%   fib(20, _) :  ~ 21,000 inferences      (ratio ~11x, phi^5 ~ 11.1)
%   fib(25, _) :  ~240,000 inferences       (ratio ~11x)
%   fib(30, _) :  ~2,700,000 inferences     (ratio ~11x)
% The ratio between consecutive 5-step jumps is ~phi^5 ~ 11.1, confirming O(phi^n).

% Solution 5.4:
% fib_memo is faster on the FIRST call because of the bottom-up caching.
% When computing fib_memo(30, R):
%   - fib_memo(2, R) calls fib_memo(1, _) and fib_memo(0, _) (base cases)
%   - It then caches fib_memo(2, 2).
%   - fib_memo(3, R) calls fib_memo(2, _) (CACHED!) and fib_memo(1, _)
%   - Each subsequent computation benefits from ALL prior cached values.
% So even the first call only computes each fib(k) once: O(n) total.
% Without memo, fib(30) recomputes fib(1) about 832,040 times!

% Solution 5.5:
:- dynamic binom_cache/3.

binom(_, 0, 1) :- !.
binom(N, N, 1) :- !.
binom(N, K, R) :-
    K > 0, K < N,
    ( binom_cache(N, K, R) -> true
    ;
        N1 is N - 1,
        K1 is K - 1,
        binom(N1, K1, R1),
        binom(N1, K, R2),
        R is R1 + R2,
        asserta(binom_cache(N, K, R))
    ).

clear_binom_cache :- retractall(binom_cache(_, _, _)).

% ?- binom(10, 3, R).  --> R = 120
% ?- binom(20, 10, R). --> R = 184756
