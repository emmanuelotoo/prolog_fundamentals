/* ===========================================================
   Lesson 6: Planning — The Farmer-Wolf-Goat-Cabbage Problem
   Ertel Ch. 5, Section 5.6
   ===========================================================

   A classic AI planning problem solved with Prolog state-space search.

   The farmer must transport a wolf, goat, and cabbage across a river.
   The boat holds only the farmer plus at most one item. Constraints:
   - Wolf eats goat if left alone together (without farmer).
   - Goat eats cabbage if left alone together (without farmer).

   This lesson covers:
   - State representation with compound terms
   - State transitions (go/2)
   - Safety constraints (safe/1)
   - Recursive planning with visited-state tracking
   - The situation calculus approach

   EXAM: Understand how state-space search works in Prolog and why
   the visited list is essential to prevent infinite loops.

   =========================================================== */


% ===========================================================
% PART 1: State Representation
% ===========================================================
% A state is: state(Farmer, Wolf, Goat, Cabbage)
% Each variable is either 'left' or 'right' (side of the river).
%
% Start: state(left, left, left, left)    — everyone on the left
% Goal:  state(right, right, right, right) — everyone on the right


% ===========================================================
% PART 2: River Crossing
% ===========================================================
across(left, right).
across(right, left).


% ===========================================================
% PART 3: Possible Moves (go/2)
% ===========================================================
% The farmer always crosses. He can optionally take one item.

% Farmer takes the wolf
go(state(X, X, G, C), state(Y, Y, G, C)) :- across(X, Y).

% Farmer takes the goat
go(state(X, W, X, C), state(Y, W, Y, C)) :- across(X, Y).

% Farmer takes the cabbage
go(state(X, W, G, X), state(Y, W, G, Y)) :- across(X, Y).

% Farmer crosses alone
go(state(X, W, G, C), state(Y, W, G, C)) :- across(X, Y).

% Notice: the farmer's position (1st arg) always matches the item
% he takes. After crossing, both change sides. Other items stay put.


% ===========================================================
% PART 4: Safety Constraints
% ===========================================================
% A state is safe if no unattended eating can occur.
% Wolf eats goat: dangerous when wolf and goat are on the same side
%                 but farmer is on the other side.
% Goat eats cabbage: same logic.

safe(state(F, W, G, C)) :-
    across(W, G),     % wolf and goat on opposite sides
    across(G, C).     % goat and cabbage on opposite sides
safe(state(F, F, F, _)).   % farmer with both wolf and goat
safe(state(F, _, F, F)).   % farmer with both goat and cabbage

% EXAM: The safety check is applied AFTER generating a move, not before.
% This is the "generate and test" pattern.


% ===========================================================
% PART 5: The Plan Predicate
% ===========================================================
% plan(CurrentState, GoalState, VisitedStates, Path)
%
% Key insight: the Visited list prevents revisiting states, which
% would cause infinite loops. Without it, the farmer could cross
% back and forth forever.

plan(Goal, Goal, Path, Path).   % base case: already at goal
plan(Start, Goal, Visited, Path) :-
    go(Start, Next),
    safe(Next),
    \+ member(Next, Visited),       % don't revisit states
    plan(Next, Goal, [Next|Visited], Path).

% EXAM: Why is the visited list essential?
% Prolog uses depth-first search. Without cycle detection, it would
% explore: left->right->left->right->... infinitely.
% A theorem prover with a complete calculus (like E) would handle
% this, but Prolog's DFS is incomplete without explicit cycle checks.


% ===========================================================
% PART 6: Pretty Printing (Ertel Ex 5.2)
% ===========================================================

% write_move/2: describes what happened between two states
write_move(state(X, X, G1, C1), state(Y, Y, G1, C1)) :-
    write('Farmer and wolf from '), write(X), write(' to '), write(Y), nl.
write_move(state(X, W1, X, C1), state(Y, W1, Y, C1)) :-
    write('Farmer and goat from '), write(X), write(' to '), write(Y), nl.
write_move(state(X, W1, G1, X), state(Y, W1, G1, Y)) :-
    write('Farmer and cabbage from '), write(X), write(' to '), write(Y), nl.
write_move(state(X, W, G, C), state(Y, W, G, C)) :-
    write('Farmer from '), write(X), write(' to '), write(Y), nl.

% write_path/1: print the full sequence of moves
write_path([]).
write_path([_]).           % single state, nothing to print
write_path([S1, S2|Rest]) :-
    write_move(S1, S2),
    write_path([S2|Rest]).


% ===========================================================
% PART 7: Main Entry Point
% ===========================================================

start :-
    action(state(left, left, left, left),
           state(right, right, right, right)).

action(Start, Goal) :-
    plan(Start, Goal, [Start], Path),
    nl, write('Solution:'), nl,
    write_path(Path).

% ?- start.
% Solution:
% Farmer and goat from left to right
% Farmer from right to left
% Farmer and wolf from left to right
% Farmer and goat from right to left
% Farmer and cabbage from left to right
% Farmer from right to left
% Farmer and goat from left to right
% true.


% ===========================================================
% PART 8: Finding ALL Solutions
% ===========================================================
% Adding fail forces backtracking to find all solutions:

start_all :-
    action(state(left, left, left, left),
           state(right, right, right, right)),
    fail.
start_all.

% EXAM (Ertel Ex 5.3b): If you add fail to action itself:
%   action(Start, Goal) :- plan(...), write_path(Path), fail.
% then each solution prints TWICE. Why?
% Because plan/4 can find the same path via different clause orderings
% of go/2. The four go/2 clauses are tried in order, and some states
% can be reached by the same physical move matching different clauses.
% To prevent this, ensure go/2 clauses are mutually exclusive.


% ===========================================================
% PART 9: The Logic Behind plan (from Ertel)
% ===========================================================
% In pure logic, plan can be written as:
%
%   forall z: plan(z, z)
%   forall s, z, n: [go(s, n) ^ safe(n) ^ plan(n, z)] => plan(s, z)
%
% This is much more concise than the Prolog version because:
%   1. Logic doesn't need the Path variable (output is irrelevant)
%   2. Logic doesn't need the Visited list (a complete prover
%      wouldn't loop)
%
% Prolog = Logic + Control. The extra complexity is the "Control" part.


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 6.1 (Ertel Ex 5.3a): At first glance, the variable Path
% in plan/4 seems unnecessary because it's "not changed anywhere."
% Explain what Path is needed for.
% Write your answer as a comment.


% Exercise 6.2: Trace through the first few steps of
% ?- plan(state(left,left,left,left), state(right,right,right,right), [...], Path).
% Which move is tried first? Does it pass safe/1?


% Exercise 6.3: Modify the problem for a variant where the farmer
% can carry TWO items at once. Add new go/2 clauses.

% Your code here:
% go2(state(...), state(...)) :- across(X, Y).


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 6.1:
% Path is needed for OUTPUT. It's an unbound variable that gets unified
% with the final Visited list when the base case plan(Goal, Goal, Path, Path)
% is reached. At that point, Path unifies with the accumulated visited
% states, which represents the solution path. Without Path, we'd find
% a solution but couldn't report it.
% This is the "accumulator becomes output" pattern — the Visited list
% accumulates states during recursion, and Path captures the final result
% through unification at the base case.

% Solution 6.2:
% Step 1: Start = state(left,left,left,left)
%   Try go clause 1 (farmer+wolf): Next = state(right,right,left,left)
%   Check safe: Wolf=right, Goat=left, Cabbage=left.
%     across(right, left)? yes. across(left, left)? NO. -> clause 1 of safe fails.
%     state(right, right, right, _)? No (goat is left). -> clause 2 fails.
%     state(right, _, right, right)? No. -> clause 3 fails.
%   NOT SAFE! (goat and cabbage alone on left)
%
%   Try go clause 2 (farmer+goat): Next = state(right,left,right,left)
%   Check safe: Wolf=left, Goat=right, Cabbage=left.
%     across(left, right)? yes. across(right, left)? yes. -> SAFE!
%   Check visited: not in [state(left,left,left,left)] -> OK
%   Recurse with state(right,left,right,left)...
%
% This is why the first move in the solution is always "farmer and goat."

% Solution 6.3:
% Farmer takes wolf AND goat
go2(state(X, X, X, C), state(Y, Y, Y, C)) :- across(X, Y).
% Farmer takes wolf AND cabbage
go2(state(X, X, G, X), state(Y, Y, G, Y)) :- across(X, Y).
% Farmer takes goat AND cabbage
go2(state(X, W, X, X), state(Y, W, Y, Y)) :- across(X, Y).
% Plus all original single-item moves
go2(S1, S2) :- go(S1, S2).
