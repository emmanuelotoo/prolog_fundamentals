/* ===========================================================
   Lesson 4: Lists — Append, Reverse, and Complexity
   Ertel Ch. 5, Section 5.4
   ===========================================================

   Lists are Prolog's fundamental data structure. This lesson covers:
   - List notation and pattern matching
   - append/3
   - Naive reverse (O(n^2)) vs accumulator reverse (O(n))
   - Tree representation with nested lists
   - Timing with time/1

   EXAM: The complexity comparison of naive vs accumulator reverse
   is one of the most commonly tested Prolog topics.

   =========================================================== */


% ===========================================================
% PART 1: List Notation
% ===========================================================
% A list is either:
%   []           the empty list
%   [H|T]        H is the head (first element), T is the tail (a list)
%
% Syntactic sugar:
%   [a, b, c]  =  [a | [b | [c | []]]]
%
% Pattern matching examples:
%   [H|T] = [1, 2, 3]       -->  H = 1, T = [2, 3]
%   [_, X|_] = [a, b, c, d] -->  X = b
%   [X, Y] = [1, 2, 3]      -->  fails! [X,Y] has 2 elements, not 3

% Try:
%   ?- [H|T] = [a, 2, 2, b, 3, 4, 5].
%   H = a, T = [2, 2, b, 3, 4, 5]     (from Ertel's example)


% ===========================================================
% PART 2: Trees as Nested Lists (from Ertel Sect 5.4)
% ===========================================================
%
% Trees without labels on inner nodes:
%     *
%    / \         is represented as  [b, c]
%   b   c
%
%      *
%    / | \       is represented as  [[e,f,g], [h], d]
%   *  *  d
%  /|\ |
% e f g h
%
% Trees with labels on inner nodes (label = head, children = tail):
%     a
%    / \         is represented as  [a, b, c]
%   b   c
%
%        a
%      / | \     is represented as  [a, [b,e,f,g], [c,h], d]
%     b  c  d
%    /|\ |
%   e f g h


% ===========================================================
% PART 3: my_append/3
% ===========================================================
% append(X, Y, Z) — Z is the result of appending Y to X.
% This is Prolog's most famous predicate.

my_append([], L, L).
my_append([X|L1], L2, [X|L3]) :- my_append(L1, L2, L3).

% Declarative reading:
%   - Appending anything to [] gives that thing.
%   - Appending L2 to [X|L1] gives [X|L3] if appending L2 to L1 gives L3.
%
% EXAM: Be able to trace through append step by step.
%
% Trace of ?- my_append([a, b, c], [d, 1, 2], Z).
%
%   my_append([a, b, c], [d,1,2], Z)
%     X=a, L1=[b,c], L2=[d,1,2], Z=[a|L3]
%     my_append([b, c], [d,1,2], L3)
%       X=b, L1=[c], L2=[d,1,2], L3=[b|L3']
%       my_append([c], [d,1,2], L3')
%         X=c, L1=[], L2=[d,1,2], L3'=[c|L3'']
%         my_append([], [d,1,2], L3'')
%           L3'' = [d,1,2]     (base case)
%       L3' = [c, d, 1, 2]
%     L3 = [b, c, d, 1, 2]
%   Z = [a, b, c, d, 1, 2]

% EXAM: append is RELATIONAL, not just a function.
% You can use it "backwards":
%   ?- my_append(X, [1,2,3], [4,5,6,1,2,3]).
%   X = [4, 5, 6]
%
%   ?- my_append(X, Y, [a, b, c]).
%   X = [], Y = [a,b,c] ;
%   X = [a], Y = [b,c] ;
%   X = [a,b], Y = [c] ;
%   X = [a,b,c], Y = []

% Complexity of append: O(n) where n = length of first list.
% It must traverse the entire first list to reach [].


% ===========================================================
% PART 4: Common List Predicates
% ===========================================================

my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).
% ?- my_member(b, [a, b, c]).  --> true

my_length([], 0).
my_length([_|T], N) :- my_length(T, N1), N is N1 + 1.
% ?- my_length([a, b, c], N).  --> N = 3

my_last([X], X).
my_last([_|T], X) :- my_last(T, X).
% ?- my_last([a, b, c], X).  --> X = c


% ===========================================================
% PART 5: Naive Reverse — O(n^2)
% ===========================================================
% From Ertel: reduces reversal of [H|T] to reversal of T, then appends [H].

nrev([], []).
nrev([H|T], R) :- nrev(T, RT), my_append(RT, [H], R).

% Trace of ?- nrev([a, b, c], R).
%
%   nrev([a,b,c], R)
%     nrev([b,c], RT1)
%       nrev([c], RT2)
%         nrev([], RT3)
%           RT3 = []                        (base case)
%         my_append([], [c], RT2)
%           RT2 = [c]
%       my_append([c], [b], RT1)
%         RT1 = [c, b]
%     my_append([c, b], [a], R)
%       R = [c, b, a]

% EXAM: Complexity analysis of nrev.
%
% For a list of length n:
%   nrev makes n recursive calls.
%   At depth k, it calls append on a list of length k.
%   Total append work: 0 + 1 + 2 + ... + (n-1) = n(n-1)/2 = O(n^2)
%
% This is why it's called NAIVE reverse — quadratic is terrible!


% ===========================================================
% PART 6: Accumulator Reverse — O(n)
% ===========================================================
% Uses an extra argument (the accumulator) to build the result
% incrementally. No append needed!

accrev(List, Reversed) :- accrev(List, [], Reversed).

accrev([], A, A).
accrev([H|T], A, R) :- accrev(T, [H|A], R).

% Trace of ?- accrev([a, b, c, d], R).
%
%   List          Accumulator
%   [a, b, c, d]  []
%   [b, c, d]     [a]
%   [c, d]        [b, a]
%   [d]           [c, b, a]
%   []            [d, c, b, a]    <-- base case: A = R
%
%   R = [d, c, b, a]

% EXAM: Complexity of accrev.
%
% For a list of length n:
%   accrev makes n recursive calls.
%   Each call does O(1) work: just [H|A] (cons is constant time).
%   Total: O(n)
%
% EXAM: This is THE classic example of the accumulator pattern.
% Know when and why to use accumulators.


% ===========================================================
% PART 7: Timing with time/1
% ===========================================================
% SWI-Prolog's time/1 reports inferences and CPU time.
%
% Generate a large list and time both reverses:
%   ?- numlist(1, 1000, L), time(nrev(L, _)).
%   ?- numlist(1, 1000, L), time(accrev(L, _)).
%
% You should see nrev is dramatically slower.
% For n=1000: nrev ~ 500,000 inferences, accrev ~ 1,000 inferences.


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 4.1 (Ertel Ex 5.6): Measure the runtime of nrev and accrev
% for lists of length 100, 500, 1000, 2000. Record the number of
% inferences. Does it match the theoretical O(n^2) vs O(n)?
%
% Use:  ?- numlist(1, N, L), time(nrev(L, _)).
%       ?- numlist(1, N, L), time(accrev(L, _)).


% Exercise 4.2: Write palindrome(L) that checks if L is a palindrome
% (reads the same forwards and backwards).
% Hint: use accrev.

% Your code here:
% palindrome(L) :- ...


% Exercise 4.3: Write my_flatten(NestedList, FlatList) that flattens
% arbitrarily nested lists.
% Example: my_flatten([a, [b, [c, d], e]], [a, b, c, d, e]).
% Hint: use is_list/1 to check if something is a list.

% Your code here:
% my_flatten([], []).
% my_flatten([H|T], Flat) :- ...


% Exercise 4.4: Trace through my_append([x, y], [z], R) step by step.
% Write the trace as a comment.


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 4.2:
palindrome(L) :- accrev(L, L).
% ?- palindrome([a, b, c, b, a]).  --> true
% ?- palindrome([a, b, c]).        --> false

% Solution 4.3:
my_flatten([], []).
my_flatten([H|T], Flat) :-
    is_list(H), !,
    my_flatten(H, FH),
    my_flatten(T, FT),
    append(FH, FT, Flat).
my_flatten([H|T], [H|FT]) :-
    my_flatten(T, FT).
% ?- my_flatten([a, [b, [c, d], e]], X).
% X = [a, b, c, d, e]

% Solution 4.4:
% Trace of ?- my_append([x, y], [z], R).
%
%   my_append([x, y], [z], R)
%     clause 2: X=x, L1=[y], L2=[z], R=[x|L3]
%     my_append([y], [z], L3)
%       clause 2: X=y, L1=[], L2=[z], L3=[y|L3']
%       my_append([], [z], L3')
%         clause 1: L3' = [z]
%     L3 = [y, z]
%   R = [x, y, z]
