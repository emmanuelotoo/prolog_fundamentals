/* ===========================================================
   Lesson 1: Facts, Rules, and Queries — Horn Clauses in Prolog
   Ertel Ch. 5, Section 5.2
   ===========================================================

   PROLOG syntax is restricted to Horn clauses. Here is the mapping
   between predicate logic (PL1 / clause normal form) and Prolog:

   PL1 / Clause Normal Form              Prolog              Type
   ---------------------------------------------------------------
   A                                      A.                  Fact
   (A1 ^ ... ^ Am) => B                   B :- A1, ..., Am.   Rule
   ~(A1 ^ ... ^ Am)                       ?- A1, ..., Am.     Query

   Key idea (Kowalski):  Algorithm = Logic + Control
   Prolog provides the logic; the interpreter provides the control
   (top-to-bottom clause selection, left-to-right goal resolution,
    depth-first search with backtracking).

   TERMINOLOGY:
   - Atom:      a lowercase constant, e.g. socrates, romeo, anne
   - Variable:  starts with uppercase or _, e.g. X, Name, _Temp
   - _          anonymous variable (each occurrence is independent)
   - Functor:   the name of a predicate, e.g. loves in loves(romeo, juliet)
   - Arity:     number of arguments, e.g. loves/2 has arity 2
   - Term:      an atom, variable, number, or compound term f(t1,...,tn)

   LOADING FILES in SWI-Prolog:
     ?- [lesson_01_facts_rules].     % short form
     ?- consult(lesson_01_facts_rules).  % equivalent

   =========================================================== */


% ===========================================================
% PART 1: Facts
% ===========================================================
% A fact is a Horn clause with an empty body.
% It states something unconditionally true in our world.

human(socrates).
human(plato).
human(aristotle).

mortal(X) :- human(X).
% Declarative reading: "X is mortal if X is human."
% Procedural reading: "To prove mortal(X), first prove human(X)."

% EXAM: Know the difference between declarative and procedural readings.

% Try these queries:
%   ?- human(socrates).          --> true
%   ?- human(zeus).              --> false (closed-world assumption)
%   ?- mortal(socrates).         --> true (derived via rule)
%   ?- mortal(X).                --> X = socrates ; X = plato ; X = aristotle


% ===========================================================
% PART 2: Rules
% ===========================================================
% A rule has a head and a body separated by :-
% Head :- Body.   means   "Head is true if Body is true."

parent(tom, bob).       % tom is a parent of bob
parent(tom, liz).
parent(bob, ann).
parent(bob, pat).

grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
% Declarative: "X is a grandparent of Z if X is a parent of Y and Y is a parent of Z."

% Try:
%   ?- grandparent(tom, ann).    --> true
%   ?- grandparent(tom, X).      --> X = ann ; X = pat
%   ?- grandparent(X, Y).        --> X = tom, Y = ann ; X = tom, Y = pat


% ===========================================================
% PART 3: Unification
% ===========================================================
% Unification is the fundamental mechanism by which Prolog matches terms.
%
%   =/2   Unification operator: succeeds if two terms can be made identical
%         by substituting variables.
%
%   ==/2  Structural equality: succeeds only if two terms are already
%         identical (no substitution performed).
%
% Examples:
%   ?- f(X, b) = f(a, Y).       --> X = a, Y = b  (unification succeeds)
%   ?- f(X, b) == f(a, b).      --> false (X is not yet bound to a)
%   ?- X = a, f(X, b) == f(a,b). --> true (X is now bound)

% EXAM: Unification finds the most general unifier (MGU).
% Two terms unify if there exists a substitution making them identical.


% ===========================================================
% PART 4: Multiple clauses and backtracking
% ===========================================================
% When a predicate has multiple clauses, Prolog tries them top-to-bottom.
% If one fails, it backtracks and tries the next.

color(red).
color(green).
color(blue).

% ?- color(X).  --> X = red ; X = green ; X = blue
% Pressing ; forces backtracking to find the next solution.


% ===========================================================
% PART 5: Anonymous variable _
% ===========================================================
% Each _ is an independent variable. Use it when you don't need the value.

has_child(X) :- parent(X, _).
% "X has a child if X is the parent of someone (we don't care who)."

% ?- has_child(tom).   --> true
% ?- has_child(ann).   --> false


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 1.1: Write facts for a small "likes" knowledge base.
%   - alice likes chocolate
%   - alice likes ice_cream
%   - bob likes pizza
%   - bob likes chocolate
% Then write a rule: friends(X, Y) :- ... that says X and Y are friends
% if they both like the same thing and X \= Y (X is not Y).

% Your code here:
% likes(alice, chocolate).
% ...
% friends(X, Y) :- ...


% Exercise 1.2: Predict the results of these queries (write your answers
% as comments, then verify in SWI-Prolog):
%   ?- parent(tom, X), parent(X, Y).
%   ?- human(X), \+ mortal(X).
%   ?- f(a, X) = f(Y, b).


% Exercise 1.3: Why are loves(X, Y) and loves(Y, X) NOT the same clause?
% Write your explanation as a comment.


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 1.1:
likes(alice, chocolate).
likes(alice, ice_cream).
likes(bob, pizza).
likes(bob, chocolate).

friends(X, Y) :- likes(X, Thing), likes(Y, Thing), X \= Y.
% ?- friends(alice, bob).  --> true (both like chocolate)
% ?- friends(X, Y).        --> X = alice, Y = bob ; X = bob, Y = alice

% Solution 1.2:
%   ?- parent(tom, X), parent(X, Y).
%       X = bob, Y = ann ; X = bob, Y = pat
%   (liz has no children, so parent(liz, Y) fails)
%
%   ?- human(X), \+ mortal(X).
%       false (every human is mortal by our rule)
%
%   ?- f(a, X) = f(Y, b).
%       X = b, Y = a  (unification: a=Y, X=b)

% Solution 1.3:
%   loves(X, Y) and loves(Y, X) are different because variable names
%   are positional. loves(X, Y) means "the first argument loves the
%   second." loves(Y, X) means the same structurally but with swapped
%   positions. In a rule like:
%     loves(juliet, romeo) :- loves(romeo, juliet).
%   the head has juliet in position 1 and romeo in position 2 — this
%   is a DIFFERENT fact than loves(romeo, juliet) where romeo is in
%   position 1.
