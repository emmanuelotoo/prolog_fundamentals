/* ===========================================================
   Lesson 2: Family Relationships, Search Trees, Backtracking
   Ertel Ch. 5, Section 5.2
   ===========================================================

   This lesson implements the family relationship examples from Ertel.
   We explore:
   - child/3 with symmetry in the parent arguments
   - descendant/2 with recursion
   - The infinite loop problem and how to fix it
   - Declarative vs procedural semantics
   - Search trees

   EXAM: Be able to draw search trees and explain why certain
   clause orderings cause infinite loops.

   =========================================================== */


% ===========================================================
% PART 1: The Family Database (from Ertel Fig. 5.1)
% ===========================================================
% child_fact(Child, Mother, Father).
% We use child_fact for the raw data, and child for the symmetric view.

child_fact(oscar, karen, frank).
child_fact(mary, karen, frank).
child_fact(eve, anne, oscar).
child_fact(henry, anne, oscar).
child_fact(isolde, anne, oscar).
child_fact(clyde, mary, oscarb).


% ===========================================================
% PART 2: The Symmetry Problem
% ===========================================================
% Ertel's first attempt (Fig. 5.1) uses a recursive rule for symmetry:
%
%   child(X, Z, Y) :- child(X, Y, Z).    % DANGEROUS!
%
% This makes child/3 symmetric in the 2nd and 3rd arguments, but
% it calls itself recursively without a base case change, leading
% to infinite loops for some queries.
%
% EXAM: Understand WHY this causes an infinite loop.
% When Prolog tries child(X, Z, Y), it generates subgoal child(X, Y, Z),
% which generates child(X, Z, Y), which generates child(X, Y, Z), ...

% The SAFE version separates facts from the symmetry rule:

child(X, Y, Z) :- child_fact(X, Y, Z).
child(X, Z, Y) :- child_fact(X, Y, Z).

% Now child/3 is NOT recursive — it always bottoms out at child_fact/3.

% Try:
%   ?- child(eve, oscar, anne).   --> true  (via 2nd clause)
%   ?- child(eve, anne, oscar).   --> true  (via 1st clause)


% ===========================================================
% PART 3: Descendant — Recursive Predicate
% ===========================================================
% descendant(X, Y) means "X is a descendant of Y"

descendant(X, Y) :- child(X, Y, _).
descendant(X, Y) :- child(X, U, _), descendant(U, Y).

% Declarative reading:
%   "X is a descendant of Y if X is a child of Y (base case),
%    or X is a child of U and U is a descendant of Y (recursive case)."
%
% Procedural reading:
%   "To prove descendant(X,Y):
%    1. Try clause 1: prove child(X, Y, _).
%    2. If that fails, try clause 2: find a U such that child(X, U, _),
%       then recursively prove descendant(U, Y)."

% EXAM: Declarative vs procedural semantics is a core exam concept.

% Try:
%   ?- descendant(eve, karen).    --> true (eve->oscar->karen)
%   ?- descendant(clyde, karen).  --> true (clyde->mary->karen)
%   ?- descendant(X, karen).      --> X = oscar ; X = mary ; X = eve ; ...


% ===========================================================
% PART 4: Search Tree for child(eve, oscar, anne)
% ===========================================================
%
% Query: ?- child(eve, oscar, anne).
%
%                    child(eve, oscar, anne)
%                    /                    \
%          clause 1:                    clause 2:
%     child_fact(eve, oscar, anne)   child_fact(eve, anne, oscar)
%              |                              |
%            FAIL                          SUCCESS (fact #3)
%     (no matching fact)
%
% Prolog tries clause 1 first: looks for child_fact(eve, oscar, anne).
% No such fact exists -> FAIL -> backtrack to clause 2.
% Clause 2 looks for child_fact(eve, anne, oscar) -> matches fact #3 -> SUCCESS.
%
% EXAM: Be able to draw search trees like this for any query.


% ===========================================================
% PART 5: Search Tree for descendant(clyde, karen)
% ===========================================================
%
% Query: ?- descendant(clyde, karen).
%
%                  descendant(clyde, karen)
%                  /                      \
%         clause 1:                    clause 2:
%    child(clyde, karen, _)       child(clyde, U, _), descendant(U, karen)
%           |                              |
%      try child_fact               U = mary (from child_fact(clyde, mary, oscarb))
%      matches? NO                         |
%      try swapped? NO              descendant(mary, karen)
%           |                        /                \
%         FAIL                 clause 1:           clause 2:
%                         child(mary, karen, _)       ...
%                               |
%                        child_fact(mary, karen, frank)
%                               |
%                            SUCCESS!
%
% EXAM: The key insight is that Prolog uses depth-first search with
% backtracking. It explores the leftmost branch fully before trying
% alternatives.


% ===========================================================
% PART 6: Why Ertel's original program loops
% ===========================================================
% If we had written (DO NOT UNCOMMENT — will loop!):
%
%   child(oscar, karen, frank).
%   child(mary, karen, frank).
%   ...
%   child(X, Z, Y) :- child(X, Y, Z).     % recursive symmetry
%
%   descendant(X, Y) :- child(X, Y, Z).
%   descendant(X, Y) :- child(X, U, V), descendant(U, Y).
%
% Then ?- descendant(clyde, karen) would:
%   1. Try clause 1 of descendant: child(clyde, karen, Z)
%   2. Fail on facts, try symmetry rule: child(clyde, Z, karen)
%   3. Fail on facts, try symmetry rule: child(clyde, karen, Z)  <- LOOP!
%
% The symmetry rule calls itself forever.
% Our fix (child_fact + two non-recursive child clauses) avoids this.


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 2.1: Draw the search tree for ?- descendant(henry, frank).
% (Hint: henry -> oscar -> frank, it will take 2 recursive steps.)
% Write it as a comment in ASCII art.


% Exercise 2.2: Define sibling(X, Y) — X and Y are siblings if they
% share at least one parent and are not the same person.
% Hint: use child_fact/3.

% Your code here:
% sibling(X, Y) :- ...


% Exercise 2.3: Define ancestor(X, Y) — the inverse of descendant.
% "X is an ancestor of Y" means "Y is a descendant of X."

% Your code here:
% ancestor(X, Y) :- ...


% Exercise 2.4: What happens if you swap the two clauses of descendant?
%   descendant(X, Y) :- child(X, U, _), descendant(U, Y).  % recursive first
%   descendant(X, Y) :- child(X, Y, _).                     % base case second
% Does it still terminate for ?- descendant(clyde, karen)? Why or why not?
% Write your answer as a comment.


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 2.1: Search tree for ?- descendant(henry, frank).
%
%               descendant(henry, frank)
%               /                      \
%      clause 1:                    clause 2:
% child(henry, frank, _)     child(henry, U, _), descendant(U, frank)
%        |                              |
%      FAIL                    U = anne (child_fact(henry, anne, oscar))
%  (no match)                          |
%                              descendant(anne, frank)
%                              /                    \
%                     clause 1:                  clause 2:
%                child(anne, frank, _)     child(anne, U2, _), descendant(U2, frank)
%                       |                           |
%                     FAIL                       FAIL (anne has no parents in KB)
%                  (no match)
%
%      Also: U = oscar (child(henry, oscar, _) via swapped child_fact)
%                              |
%                      descendant(oscar, frank)
%                      /                      \
%             clause 1:                    clause 2:
%        child(oscar, frank, _)     child(oscar, U3, _), descendant(U3, frank)
%               |                              |
%         FAIL? Let's check:           U3 = karen (child_fact(oscar, karen, frank))
%    child_fact(oscar, frank, _)?             |
%         NO match                    descendant(karen, frank)
%    swapped: child_fact(oscar, _, frank)?        |
%         YES: child_fact(oscar, karen, frank)   ... (karen has no parents -> FAIL)
%               |
%            SUCCESS!

% Solution 2.2:
sibling(X, Y) :-
    child_fact(X, Mother, Father),
    child_fact(Y, Mother, Father),
    X \= Y.
% ?- sibling(eve, henry).   --> true
% ?- sibling(oscar, mary).  --> true
% ?- sibling(X, eve).       --> X = henry ; X = isolde

% Solution 2.3:
ancestor(X, Y) :- descendant(Y, X).
% ?- ancestor(karen, clyde).  --> true

% Solution 2.4:
% If we swap the clauses:
%   descendant(X, Y) :- child(X, U, _), descendant(U, Y).  % recursive first
%   descendant(X, Y) :- child(X, Y, _).                     % base case second
%
% It STILL TERMINATES for ?- descendant(clyde, karen) because:
% - Prolog tries the recursive clause first, finds child(clyde, U, _)
%   with U = mary, then tries descendant(mary, karen).
% - For descendant(mary, karen), it again tries recursive first,
%   finds child(mary, U2, _) with U2 = karen, then tries
%   descendant(karen, karen).
% - For descendant(karen, karen), child(karen, U3, _) FAILS
%   (karen has no children in the KB), so it backtracks to clause 2.
% - Clause 2: child(karen, karen, _) also fails -> overall fail for
%   this branch.
% - Backtrack: clause 2 of descendant(mary, karen):
%   child(mary, karen, _) -> SUCCESS via child_fact(mary, karen, frank).
%
% So it terminates, but the search path is longer. In general, putting
% the base case first is more efficient and avoids potential issues
% with infinite branches in deeper recursions.
