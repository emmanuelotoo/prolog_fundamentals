/* ===========================================================
   Lesson 8: Combined Exam Practice
   Ertel Ch. 5, Sections 5.2-5.9
   ===========================================================

   Mixed exam-style questions covering all topics.
   Try each one before looking at the solutions.

   Types of questions:
   (A) Predict output / trace execution
   (B) Write a predicate
   (C) Explain a concept
   (D) Draw a search tree (answer in comments)

   =========================================================== */

:- use_module(library(clpfd)).


% ===========================================================
% Q1 (Type A): What does this program output?
% ===========================================================
%
%   p(1).
%   p(2) :- !.
%   p(3).
%
%   ?- p(X), write(X), nl, fail.
%
% Write your prediction here:
%


% ===========================================================
% Q2 (Type A): What does this program output?
% ===========================================================
%
%   foo(X, Y) :- X > 0, !, Y is X * 2.
%   foo(_, 0).
%
%   ?- foo(3, A), foo(-1, B), write(A-B), nl.
%
% Write your prediction here:
%


% ===========================================================
% Q3 (Type B): Write subset/2
% ===========================================================
% subset(S, L) succeeds if every element of S is a member of L.
% Example: subset([a, c], [a, b, c, d]) --> true
%          subset([a, x], [a, b, c])    --> false

% Your code here:
% subset([], _).
% subset([H|T], L) :- ...


% ===========================================================
% Q4 (Type A): Trace append
% ===========================================================
% Trace the execution of:
%   ?- append([a, b], [c, d], X).
% Show each recursive call, the unification at each step,
% and the final result.
%
% Your trace here:
%


% ===========================================================
% Q5 (Type B): Write a memoized catalan/2
% ===========================================================
% The Catalan numbers: C(0)=1, C(n) = sum_{i=0}^{n-1} C(i)*C(n-1-i)
% Or equivalently: C(n) = C(n-1) * 2*(2n-1) / (n+1)  [simpler formula]
%
% Use the simpler recurrence: C(0)=1, C(n) = C(n-1) * 2*(2*n-1) // (n+1)
% Memoize with asserta.

:- dynamic catalan_cache/2.

% Your code here:
% catalan(0, 1).
% catalan(N, R) :- ...


% ===========================================================
% Q6 (Type C): Explain negation as failure
% ===========================================================
% Why does this query fail?
%   ?- \+ member(X, [a, b, c]).
%
% Write your explanation:
%


% ===========================================================
% Q7 (Type D): Draw search tree
% ===========================================================
% Given:
%   parent(tom, bob).
%   parent(bob, ann).
%   parent(bob, pat).
%   ancestor(X, Y) :- parent(X, Y).
%   ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
%
% Draw the search tree for: ?- ancestor(tom, X).
%
% Your tree here (ASCII art):
%


% ===========================================================
% Q8 (Type B): Write a CLP 4-queens solver from scratch
% ===========================================================
% Place 4 queens on a 4x4 board. Queens = [Q1,Q2,Q3,Q4] where
% Qi = row of queen in column i.

% Your code here:
% four_queens([Q1, Q2, Q3, Q4]) :- ...


% ===========================================================
% Q9 (Type C): Declarative vs procedural semantics
% ===========================================================
% Given:
%   path(X, Y) :- edge(X, Y).
%   path(X, Y) :- edge(X, Z), path(Z, Y).
%   edge(a, b). edge(b, c). edge(c, a).
%
% (a) What is the declarative reading of path?
% (b) Does ?- path(a, c). terminate? Why or why not?
% (c) How would you fix it?
%
% Your answers:
%


% ===========================================================
% Q10 (Type B): Write intersection/3
% ===========================================================
% intersection(L1, L2, L3) where L3 contains elements in both L1 and L2.
% Example: intersection([a,b,c], [b,c,d], [b,c]).

% Your code here:
% intersection([], _, []).
% intersection([H|T], L2, Result) :- ...


% ===========================================================
% Q11 (Type A): Assert and backtracking
% ===========================================================
% :- dynamic count/1.
% count(0).
%
% inc :- retract(count(N)), N1 is N+1, asserta(count(N1)).
%
% What is the value of count after:
%   ?- inc, inc, inc.
%   ?- count(X).
%
% And after:
%   ?- (inc, inc, fail) ; true.
%   ?- count(X).
%
% Write your predictions:
%


% ===========================================================
% Q12 (Type C): Why asserta for memoization?
% ===========================================================
% When memoizing with assert, why use asserta (add at beginning)
% rather than assertz (add at end)? What would happen with assertz?
%
% Your answer:
%


% === SOLUTIONS BELOW — try the exercises first! =========================


% --- Solution Q1 ---
% Output:
%   1
%   2
%   false.
%
% Explanation: p(1) succeeds, write(1), backtrack via fail.
% p(2) succeeds, cut is reached (commits to this clause for p),
% write(2), backtrack via fail. The cut prevents p(3) from being tried.
% Wait — actually, the cut is inside the clause for p(2), but fail is
% OUTSIDE p. The cut only affects alternatives for p within that call.
% Since fail forces backtracking past the p(X) choice point:
%   X=1: write(1), fail -> backtrack
%   X=2: cut reached (prunes X=3), write(2), fail -> backtrack
%   X=3 is pruned by the cut!
% So output is: 1\n2\n then false.


% --- Solution Q2 ---
% Output: 6-0
%
% foo(3, A): 3 > 0 succeeds, cut, A is 3*2 = 6.
% foo(-1, B): -1 > 0 fails, cut NOT reached, try clause 2: B = 0.
% write(6-0). Note: 6-0 prints as 6-0 (it's the term -(6,0)).


% --- Solution Q3 ---
subset([], _).
subset([H|T], L) :- member(H, L), subset(T, L).


% --- Solution Q4 ---
% Trace of ?- append([a, b], [c, d], X).
%
%   append([a, b], [c, d], X)
%     clause 2: X = [a|L3], subgoal: append([b], [c, d], L3)
%       clause 2: L3 = [b|L3'], subgoal: append([], [c, d], L3')
%         clause 1: L3' = [c, d]
%     L3 = [b, c, d]
%   X = [a, b, c, d]


% --- Solution Q5 ---
catalan(0, 1) :- !.
catalan(N, R) :-
    N > 0,
    ( catalan_cache(N, R) -> true
    ;
        N1 is N - 1,
        catalan(N1, R1),
        R is R1 * 2 * (2*N - 1) // (N + 1),
        asserta(catalan_cache(N, R))
    ).

clear_catalan_cache :- retractall(catalan_cache(_, _)).

% ?- catalan(5, R).   --> R = 42
% ?- catalan(10, R).  --> R = 16796


% --- Solution Q6 ---
% ?- \+ member(X, [a, b, c]).  fails because:
% \+ tries to prove member(X, [a, b, c]).
% X is unbound, so member(X, [a,b,c]) succeeds with X=a.
% Since the goal SUCCEEDED, \+ (negation as failure) FAILS.
% The problem: \+ doesn't bind variables. It just checks provability.
% With unbound X, member always succeeds, so \+ always fails.
% Fix: bind X first, e.g. X = d, \+ member(X, [a,b,c]).


% --- Solution Q7 ---
% Search tree for ?- ancestor(tom, X).
%
%                    ancestor(tom, X)
%                    /              \
%           clause 1:            clause 2:
%      parent(tom, X)       parent(tom, Z), ancestor(Z, X)
%           |                        |
%        X = bob               Z = bob
%        SUCCESS            ancestor(bob, X)
%                           /              \
%                    clause 1:          clause 2:
%               parent(bob, X)     parent(bob, Z2), ancestor(Z2, X)
%                /        \                |             |
%           X = ann    X = pat        Z2 = ann      Z2 = pat
%           SUCCESS    SUCCESS     ancestor(ann,X)  ancestor(pat,X)
%                                  /           \       /         \
%                            parent(ann,X)   ...  parent(pat,X)  ...
%                               FAIL                FAIL
%                          (no children)        (no children)
%
% Solutions in order: X = bob ; X = ann ; X = pat


% --- Solution Q8 ---
four_queens([Q1, Q2, Q3, Q4]) :-
    [Q1, Q2, Q3, Q4] ins 1..4,
    all_different([Q1, Q2, Q3, Q4]),
    abs(Q1 - Q2) #\= 1,
    abs(Q1 - Q3) #\= 2,
    abs(Q1 - Q4) #\= 3,
    abs(Q2 - Q3) #\= 1,
    abs(Q2 - Q4) #\= 2,
    abs(Q3 - Q4) #\= 1,
    label([Q1, Q2, Q3, Q4]).

% ?- four_queens(Q).
% Q = [2, 4, 1, 3] ;
% Q = [3, 1, 4, 2]


% --- Solution Q9 ---
% (a) Declarative reading: "There is a path from X to Y if there is
%     a direct edge from X to Y, or if there is an edge from X to
%     some Z and a path from Z to Y."
%
% (b) ?- path(a, c). DOES terminate and returns true.
%     path(a,c) -> try edge(a,c): FAIL.
%     Try clause 2: edge(a,Z), Z=b, path(b,c).
%     path(b,c) -> edge(b,c): SUCCESS!
%
%     BUT: if you ask for more solutions with ;, it will LOOP.
%     path(b,c) clause 2: edge(b,Z), Z=c, path(c,c).
%     path(c,c) -> edge(c,c): FAIL.
%     clause 2: edge(c,Z), Z=a, path(a,c).
%     path(a,c) -> ... back to the start -> infinite loop!
%
% (c) Fix: add a visited list, like in the planning example:
%     path(X, Y, Visited) :- edge(X, Y), \+ member(Y, Visited).
%     path(X, Y, Visited) :- edge(X, Z), \+ member(Z, Visited),
%                             path(Z, Y, [Z|Visited]).


% --- Solution Q10 ---
intersection([], _, []).
intersection([H|T], L2, [H|R]) :-
    member(H, L2), !,
    intersection(T, L2, R).
intersection([_|T], L2, R) :-
    intersection(T, L2, R).

% ?- intersection([a,b,c], [b,c,d], X).  --> X = [b, c]


% --- Solution Q11 ---
% After ?- inc, inc, inc.
%   count(X) --> X = 3
% Each inc succeeds, retract/assert persists.
%
% Then after ?- (inc, inc, fail) ; true.
%   count(X) --> X = 5
% inc, inc raises count from 3 to 5. Then fail causes backtracking.
% BUT asserted facts persist across backtracking!
% So count remains 5, not reverted to 3.
% The ; true makes the overall query succeed.
%
% EXAM: This is a key insight — assert/retract side effects survive
% backtracking. This is why they are called "extra-logical."


% --- Solution Q12 ---
% asserta adds the cached fact at the BEGINNING of the clause database.
% When Prolog looks up fib_memo(N, R), it searches clauses top to bottom.
% With asserta, cached facts come BEFORE the recursive rules, so they
% are found immediately in O(1) without entering the recursive clause.
%
% With assertz, cached facts would go at the END, after the recursive
% rules. Prolog would first try the recursive rule (which would
% eventually also find the answer), wasting time. The memoization
% would still work but would be much less effective because the
% recursive rule is always tried first.
